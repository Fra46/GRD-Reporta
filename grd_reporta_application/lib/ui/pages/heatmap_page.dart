import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';

/// Página de mapa de calor que muestra eventos con intensidad visual
/// Similar a Google Maps/Earth heatmap
class HeatmapPage extends StatelessWidget {
  const HeatmapPage({super.key});

  // Bounding box del departamento del Cesar
  static const double _latMin = 7.7;
  static const double _latMax = 10.9;
  static const double _lngMin = -74.0;
  static const double _lngMax = -72.7;

  @override
  Widget build(BuildContext context) {
    final EventController ec = Get.find<EventController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mapa de Calor - Eventos GRD'),
        backgroundColor: const Color(0xFF1B2E6B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        final eventos = ec.events;
        final eventosConGps = eventos
            .where((e) => e.latitud != null && e.longitud != null)
            .toList();

        return Stack(
          children: [
            // Mapa de calor principal
            Container(
              color: const Color(0xFFE8EEF7),
              child: CustomPaint(
                painter: _HeatmapPainter(
                  eventos: eventosConGps,
                  latMin: _latMin,
                  latMax: _latMax,
                  lngMin: _lngMin,
                  lngMax: _lngMax,
                ),
                size: Size.infinite,
              ),
            ),

            // Leyenda
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Intensidad de Eventos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildLegendItem('Baja', Colors.green),
                        const SizedBox(width: 16),
                        _buildLegendItem('Media', Colors.orange),
                        const SizedBox(width: 16),
                        _buildLegendItem('Alta', Colors.red),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${eventosConGps.length} eventos con GPS',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888899),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF555567)),
        ),
      ],
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final List<EventModel> eventos;
  final double latMin;
  final double latMax;
  final double lngMin;
  final double lngMax;

  _HeatmapPainter({
    required this.eventos,
    required this.latMin,
    required this.latMax,
    required this.lngMin,
    required this.lngMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo con gradiente
    final bgRect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFFF5F7FC), const Color(0xFFE8EEF7)],
    );
    canvas.drawRect(bgRect, Paint()..shader = gradient.createShader(bgRect));

    // Dibujar grilla
    _drawGrid(canvas, size);

    // Dibujar círculos de calor
    _drawHeatmapCircles(canvas, size);

    // Dibujar eventos individuales
    for (var evento in eventos) {
      final x = _lngToX(evento.longitud!, size.width);
      final y = _latToY(evento.latitud!, size.height);

      _drawEventPoint(canvas, x, y, evento.criticidad);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridCount = 5;
    for (int i = 0; i <= gridCount; i++) {
      final x = (size.width / gridCount) * i;
      final y = (size.height / gridCount) * i;

      // Líneas verticales
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);

      // Líneas horizontales
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawHeatmapCircles(Canvas canvas, Size size) {
    if (eventos.isEmpty) return;

    // Calcular densidad en cada zona
    const cellSize = 80.0;

    Map<String, int> cellCounts = {};

    for (var evento in eventos) {
      final x = _lngToX(evento.longitud!, size.width);
      final y = _latToY(evento.latitud!, size.height);

      final cellX = (x / cellSize).floor();
      final cellY = (y / cellSize).floor();
      final key = '$cellX,$cellY';

      cellCounts[key] = (cellCounts[key] ?? 0) + 1;
    }

    // Encontrar máxima densidad
    final maxCount = cellCounts.values.isEmpty
        ? 1
        : cellCounts.values.reduce((a, b) => a > b ? a : b);

    // Dibujar círculos de calor
    for (var entry in cellCounts.entries) {
      final parts = entry.key.split(',');
      final cellX = int.parse(parts[0]);
      final cellY = int.parse(parts[1]);
      final count = entry.value;

      final x = cellX * cellSize + cellSize / 2;
      final y = cellY * cellSize + cellSize / 2;

      // Intensidad de 0 a 1
      final intensity = count / maxCount;

      // Color basado en intensidad
      Color color;
      if (intensity > 0.7) {
        color = Colors.red;
      } else if (intensity > 0.4) {
        color = Colors.orange;
      } else {
        color = Colors.green;
      }

      // Radio basado en intensidad
      final radius = 15 + (intensity * 25);

      // Dibujar círculo con opacidad
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );

      // Círculo de borde
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = color.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawEventPoint(Canvas canvas, double x, double y, String criticidad) {
    final color = _colorPorCriticidad(criticidad);

    // Punto principal
    canvas.drawCircle(
      Offset(x, y),
      6,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // Borde blanco
    canvas.drawCircle(
      Offset(x, y),
      6,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Aura pulsante
    canvas.drawCircle(
      Offset(x, y),
      10,
      Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  double _lngToX(double lng, double width) {
    return ((lng - lngMin) / (lngMax - lngMin)) * width;
  }

  double _latToY(double lat, double height) {
    return (1 - (lat - latMin) / (latMax - latMin)) * height;
  }

  Color _colorPorCriticidad(String criticidad) {
    switch (criticidad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter oldDelegate) {
    return oldDelegate.eventos.length != eventos.length;
  }
}
