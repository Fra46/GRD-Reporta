import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../models/event_model.dart';

/// Genera un QR con los datos del evento para compartir offline.
/// El QR contiene la URL de detalle del evento + datos básicos.
class EventQrWidget extends StatelessWidget {
  final EventModel event;
  const EventQrWidget({super.key, required this.event});

  String get _qrData {
    // Formato legible para cualquier lector QR
    return [
      'GRD-REPORTA:${event.id}',
      'TIPO:${event.tipoEvento}',
      'MUNICIPIO:${event.municipio}',
      'CRITICIDAD:${event.criticidad.toUpperCase()}',
      'FECHA:${_fmt(event.fechaEvento)}',
    ].join('|');
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Column(
        children: [
          const Text(
            'Código QR del Evento',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Escanea para ver detalles',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          QrImageView(
            data: _qrData,
            version: QrVersions.auto,
            size: 180,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xFF1B2E6B),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event.id.substring(0, 8).toUpperCase(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFF1B2E6B),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}