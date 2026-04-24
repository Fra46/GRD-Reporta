import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/event_controller.dart';
import '../../../models/event_model.dart';

/// Mapa estático visual que muestra los eventos con coordenadas GPS.
/// Usa un canvas proporcional al bounding box del Cesar.
/// Cuando haya integración con Google Maps se reemplaza este widget.
class EventMapWidget extends StatelessWidget {
  const EventMapWidget({super.key});

  // Bounding box aproximado del departamento del Cesar
  static const double _latMin = 7.7;
  static const double _latMax = 10.9;
  static const double _lngMin = -74.0;
  static const double _lngMax = -72.7;

  @override
  Widget build(BuildContext context) {
    final EventController ec = Get.find<EventController>();

    return Obx(() {
      final eventosConGps = ec.events
          .where((e) => e.latitud != null && e.longitud != null)
          .toList();

      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEF7),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Fondo de mapa más visual
            CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _MapBackgroundPainter(),
            ),

            // Pins de eventos con GPS real
            if (eventosConGps.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: eventosConGps.map((e) {
                      final x = _lngToX(e.longitud!, constraints.maxWidth);
                      final y = _latToY(e.latitud!, 200);
                      return Positioned(
                        left: x - 9,
                        top: y - 20,
                        child: _EventPin(event: e),
                      );
                    }).toList(),
                  );
                },
              ),

            // Pins decorativos si no hay GPS
            if (eventosConGps.isEmpty) ...[
              Positioned(left: 90, top: 60, child: _staticPin(Colors.grey)),
              Positioned(left: 180, top: 95, child: _staticPin(Colors.grey)),
              Positioned(left: 130, top: 110, child: _staticPin(Colors.grey)),
            ],

            // Barra inferior con info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                color: Colors.white.withOpacity(0.88),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 13,
                      color: Color(0xFF1B2E6B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      eventosConGps.isNotEmpty
                          ? '${eventosConGps.length} evento(s) con GPS — '
                                '${eventosConGps.length == 1 ? eventosConGps.first.municipio : 'Cesar, Colombia'}'
                          : 'Cesar, Colombia — sin GPS aún',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF1B2E6B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Convierte longitud a posición X en el canvas
  double _lngToX(double lng, double width) {
    return ((lng - _lngMin) / (_lngMax - _lngMin)) * width;
  }

  // Convierte latitud a posición Y en el canvas (invertida)
  double _latToY(double lat, double height) {
    return (1 - (lat - _latMin) / (_latMax - _latMin)) * height;
  }

  Widget _staticPin(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        Container(width: 2, height: 6, color: color),
      ],
    );
  }
}

// ─── Pin individual de evento ───────────────────────────────────
class _EventPin extends StatelessWidget {
  final EventModel event;
  const _EventPin({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _colorPorCriticidad(event.criticidad);
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          event.tipoEvento,
          '${event.municipio} · ${event.criticidad.toUpperCase()}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Container(width: 2, height: 8, color: color),
        ],
      ),
    );
  }

  Color _colorPorCriticidad(String c) {
    switch (c.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return const Color(0xFF27AE60);
    }
  }
}

// ─── Painter de grilla de fondo ─────────────────────────────────
class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFFEFF4FB), const Color(0xFFD7E5F6)],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final route1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.75)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.55,
        size.width * 0.35,
        size.height * 0.4,
        size.width * 0.5,
        size.height * 0.45,
      )
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.5,
        size.width * 0.75,
        size.height * 0.65,
        size.width * 0.9,
        size.height * 0.55,
      );

    final route2 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.25)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.15,
        size.width * 0.45,
        size.height * 0.3,
        size.width * 0.55,
        size.height * 0.25,
      )
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.2,
        size.width * 0.75,
        size.height * 0.3,
        size.width * 0.85,
        size.height * 0.18,
      );

    canvas.drawPath(route1, linePaint);
    canvas.drawPath(route2, linePaint);

    final dotPaint = Paint()..color = const Color(0xFF1B2E6B);
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.3),
      4,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.7),
      3,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
