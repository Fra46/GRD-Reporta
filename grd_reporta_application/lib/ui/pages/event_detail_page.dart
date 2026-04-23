import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../widgets/events/event_header_widget.dart';
import '../widgets/events/info_section_widget.dart';
import '../widgets/events/detail_item_widget.dart';

class EventDetailPage extends StatelessWidget {
  final EventModel event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF1B2E6B),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Detalle Evento',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _CriticidadBadge(criticidad: event.criticidad),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  EventHeaderWidget(event: event),
                  const SizedBox(height: 16),
                  InfoSectionWidget(
                    children: [
                      DetailItemWidget(
                        title: 'Municipio',
                        value: event.municipio,
                        icon: Icons.location_city,
                      ),
                      DetailItemWidget(
                        title: 'Descripción',
                        value: event.descripcion,
                        icon: Icons.description,
                      ),
                      DetailItemWidget(
                        title: 'Fecha Evento',
                        value: _formatDate(event.fechaEvento),
                        icon: Icons.calendar_today,
                      ),
                      DetailItemWidget(
                        title: 'Registrado por',
                        value: event.usuarioNombre,
                        icon: Icons.person,
                      ),
                    ],
                  ),
                  if (event.hayAfectacion) ...[
                    const SizedBox(height: 16),
                    InfoSectionWidget(
                      title: 'Afectación',
                      children: [
                        DetailItemWidget(
                          title: 'Familias afectadas',
                          value: event.familiasAfectadas.toString(),
                          icon: Icons.people,
                        ),
                        DetailItemWidget(
                          title: 'Viviendas afectadas',
                          value: event.viviendasAfectadas.toString(),
                          icon: Icons.home,
                        ),
                        DetailItemWidget(
                          title: 'Requiere EDAN',
                          value: event.requiereEdan ? 'Sí' : 'No',
                          icon: Icons.fact_check,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _CriticidadBadge extends StatelessWidget {
  final String criticidad;
  const _CriticidadBadge({required this.criticidad});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (criticidad.toLowerCase()) {
      case 'alta':
        color = Colors.red;
        break;
      case 'media':
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        criticidad.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}