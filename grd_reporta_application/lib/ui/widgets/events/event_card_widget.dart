import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/event_model.dart';
import '../../../ui/pages/event_detail_page.dart';
import 'status_badge_widget.dart';

class EventCardWidget extends StatelessWidget {
  final EventModel event;

  const EventCardWidget({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => EventDetailPage(eventId: event.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(blurRadius: 8, color: Colors.black12),
          ],
        ),
        child: Row(
          children: [
            // Barra lateral de criticidad
            Container(
              width: 6,
              height: 72,
              decoration: BoxDecoration(
                color: _getCriticidadColor(),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.tipoEvento,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      _EstadoBadge(estado: event.estado),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${event.municipio}${event.corregimiento.isNotEmpty ? ' · ${event.corregimiento}' : ''}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF444455)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      StatusBadgeWidget(
                        text: event.criticidad.toUpperCase(),
                        color: _getCriticidadColor(),
                      ),
                      if (event.hayAfectacion)
                        const StatusBadgeWidget(
                          text: 'AFECCIÓN',
                          color: Colors.red,
                        ),
                      if (event.requiereEdan)
                        const StatusBadgeWidget(
                          text: 'EDAN',
                          color: Colors.indigo,
                        ),
                      if (event.escaladoCmgrd)
                        const StatusBadgeWidget(
                          text: 'CMGRD',
                          color: Colors.purple,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCCCCDD),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCriticidadColor() {
    switch (event.criticidad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (estado) {
      case 'en_proceso':
        color = Colors.orange;
        label = 'En proceso';
        break;
      case 'en_validacion':
        color = Colors.blue;
        label = 'En validación';
        break;
      case 'cerrado':
        color = Colors.grey;
        label = 'Cerrado';
        break;
      default:
        color = const Color(0xFF27AE60);
        label = 'Abierto';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}