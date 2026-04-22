import 'package:flutter/material.dart';

import '../../../models/event_model.dart';
import 'status_badge_widget.dart';

class EventCardWidget
    extends StatelessWidget {
  final EventModel event;

  const EventCardWidget({
    super.key,
    required this.event,
  });

  @override
  Widget build(
      BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(
              bottom: 14),
      padding:
          const EdgeInsets.all(
              18),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color:
                Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 72,
            decoration:
                BoxDecoration(
              color:
                  _getColor(),
              borderRadius:
                  BorderRadius.circular(
                      20),
            ),
          ),

          const SizedBox(
              width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  event.tipoEvento,
                  style:
                      const TextStyle(
                    fontSize:
                        17,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                const SizedBox(
                    height: 4),

                Text(
                  event.municipio,
                  style:
                      TextStyle(
                    color: Colors
                        .grey
                        .shade700,
                  ),
                ),

                const SizedBox(
                    height: 6),

                Text(
                  event.descripcion,
                  maxLines: 2,
                  overflow:
                      TextOverflow
                          .ellipsis,
                ),

                const SizedBox(
                    height: 10),

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

                    if (event
                        .requiereEdan)
                      const StatusBadgeWidget(
                        text:
                            'EDAN',
                        color:
                            Colors.indigo,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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