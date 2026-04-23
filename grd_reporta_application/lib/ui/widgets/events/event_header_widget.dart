import 'package:flutter/material.dart';

import '../../../models/event_model.dart';
import 'info_section_widget.dart';
import 'status_badge_widget.dart';

class EventHeaderWidget
    extends StatelessWidget {
  final EventModel event;

  const EventHeaderWidget({
    super.key,
    required this.event,
  });

  @override
  Widget build(
      BuildContext context) {
    return InfoSectionWidget(
      children: [
        Text(
          event.tipoEvento,
          style:
              const TextStyle(
            fontSize: 24,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
            height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusBadgeWidget(
              text: event
                  .criticidad
                  .toUpperCase(),
              color:
                  _getColor(),
            ),

            if (event
                .hayAfectacion)
              const StatusBadgeWidget(
                text:
                    'AFECCIÓN',
                color:
                    Colors.red,
              ),

            StatusBadgeWidget(
              text: event
                  .estado
                  .toUpperCase(),
              color:
                  Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Color _getColor() {
    switch (event.criticidad) {
      case 'alta':
        return Colors.red;

      case 'media':
        return Colors.orange;

      default:
        return Colors.green;
    }
  }
}