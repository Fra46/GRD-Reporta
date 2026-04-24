import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/event_model.dart';
import '../../controllers/event_controller.dart';
import 'report_event_page.dart';
import '../widgets/events/event_header_widget.dart';
import '../widgets/events/info_section_widget.dart';
import '../widgets/events/detail_item_widget.dart';
import '../widgets/evidence_picker_widget.dart';

class EventDetailPage extends StatelessWidget {
  // Recibimos solo el ID — el widget siempre lee el estado fresco del controller
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final EventController eventController = Get.find<EventController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Obx(() {
        // Buscar el evento actualizado en la lista reactiva
        final idx = eventController.events.indexWhere((e) => e.id == eventId);

        if (idx == -1) {
          // Evento no encontrado (puede pasar si se eliminó)
          return const Center(child: Text('Evento no encontrado'));
        }

        final event = eventController.events[idx];

        return Column(
          children: [
            // ── Header ──────────────────────────────────────────
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
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Get.back(),
                      ),
                      const Expanded(
                        child: Text(
                          'Detalle del Evento',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _CriticidadBadge(criticidad: event.criticidad),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            Get.to(() => ReportEventPage(existingEvent: event)),
                        tooltip: 'Editar evento',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Contenido ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    EventHeaderWidget(event: event),
                    const SizedBox(height: 16),

                    // Información general
                    InfoSectionWidget(
                      title: 'Información General',
                      children: [
                        DetailItemWidget(
                          title: 'Tipo de Evento',
                          value: event.tipoEvento,
                          icon: Icons.warning_amber_rounded,
                        ),
                        DetailItemWidget(
                          title: 'Municipio',
                          value: event.municipio,
                          icon: Icons.location_city_rounded,
                        ),
                        if (event.corregimiento.isNotEmpty)
                          DetailItemWidget(
                            title: 'Corregimiento / Vereda',
                            value: event.corregimiento,
                            icon: Icons.map_outlined,
                          ),
                        if (event.ubicacion.isNotEmpty)
                          DetailItemWidget(
                            title: 'Coordenadas GPS',
                            value: event.ubicacion,
                            icon: Icons.gps_fixed_rounded,
                          ),
                        DetailItemWidget(
                          title: 'Descripción',
                          value: event.descripcion,
                          icon: Icons.description_rounded,
                        ),
                        DetailItemWidget(
                          title: 'Fecha del Evento',
                          value: _formatDate(event.fechaEvento),
                          icon: Icons.calendar_today_rounded,
                        ),
                        DetailItemWidget(
                          title: 'Registrado por',
                          value: event.usuarioNombre,
                          icon: Icons.person_rounded,
                        ),
                      ],
                    ),

                    // Afectación
                    if (event.hayAfectacion) ...[
                      const SizedBox(height: 16),
                      InfoSectionWidget(
                        title: 'Afectación',
                        children: [
                          DetailItemWidget(
                            title: 'Personas afectadas',
                            value: event.personasAfectadas.toString(),
                            icon: Icons.person_pin_rounded,
                          ),
                          DetailItemWidget(
                            title: 'Familias directas',
                            value: event.familiasAfectadas.toString(),
                            icon: Icons.people_alt_rounded,
                          ),
                          DetailItemWidget(
                            title: 'Familias indirectas',
                            value: event.familiasIndirectas.toString(),
                            icon: Icons.people_outline_rounded,
                          ),
                          DetailItemWidget(
                            title: 'Viviendas afectadas',
                            value: event.viviendasAfectadas.toString(),
                            icon: Icons.home_rounded,
                          ),
                          DetailItemWidget(
                            title: 'Viviendas destruidas',
                            value: event.viviendasDestruidas.toString(),
                            icon: Icons.home_work_rounded,
                          ),
                          if (event.hectareasAfectadas > 0)
                            DetailItemWidget(
                              title: 'Hectáreas afectadas',
                              value:
                                  '${event.hectareasAfectadas.toStringAsFixed(1)} ha',
                              icon: Icons.grass_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _AfectacionChart(event: event),
                    ],

                    // Activación institucional
                    const SizedBox(height: 16),
                    InfoSectionWidget(
                      title: 'Activación Institucional',
                      children: [
                        DetailItemWidget(
                          title: 'Requiere EDAN',
                          value: event.requiereEdan ? 'Sí' : 'No',
                          icon: Icons.fact_check_rounded,
                        ),
                        DetailItemWidget(
                          title: 'Escalado CMGRD',
                          value: event.escaladoCmgrd ? 'Sí' : 'No',
                          icon: Icons.account_balance_rounded,
                        ),
                        DetailItemWidget(
                          title: 'Apoyo UNGRD',
                          value: event.apoyoUngrd ? 'Sí' : 'No',
                          icon: Icons.support_agent_rounded,
                        ),
                        DetailItemWidget(
                          title: 'Apoyo Departamento',
                          value: event.apoyoDepartamento ? 'Sí' : 'No',
                          icon: Icons.domain_rounded,
                        ),
                        DetailItemWidget(
                          title: 'Apoyo Municipio',
                          value: event.apoyoMunicipio ? 'Sí' : 'No',
                          icon: Icons.location_city_rounded,
                        ),
                      ],
                    ),

                    // Acción tomada
                    if (event.accionTomada.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      InfoSectionWidget(
                        title: 'Acción Tomada',
                        children: [
                          DetailItemWidget(
                            title: 'Acción',
                            value: event.accionTomada,
                            icon: Icons.assignment_turned_in_rounded,
                          ),
                          if (event.observacion.isNotEmpty)
                            DetailItemWidget(
                              title: 'Observaciones',
                              value: event.observacion,
                              icon: Icons.note_rounded,
                            ),
                        ],
                      ),
                    ],

                    // Fotos — usa EvidencePickerWidget para ver Y agregar
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(blurRadius: 8, color: Colors.black12),
                        ],
                      ),
                      child: EvidencePickerWidget(eventId: eventId),
                    ),

                    // Cambio de estado
                    const SizedBox(height: 24),
                    _CambiarEstadoWidget(
                      event: event,
                      controller: eventController,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

class _AfectacionChart extends StatelessWidget {
  final EventModel event;

  const _AfectacionChart({required this.event});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ChartItem(
        'Personas',
        event.personasAfectadas.toDouble(),
        const Color(0xFF1B2E6B),
      ),
      _ChartItem(
        'Familias directas',
        event.familiasAfectadas.toDouble(),
        const Color(0xFF2ECC71),
      ),
      _ChartItem(
        'Familias indirectas',
        event.familiasIndirectas.toDouble(),
        const Color(0xFFFFB74D),
      ),
      _ChartItem(
        'Viviendas',
        event.viviendasAfectadas.toDouble(),
        const Color(0xFF5589FF),
      ),
    ];

    final maxValue = items
        .map((item) => item.value)
        .fold<double>(0, (prev, val) => val > prev ? val : prev);
    final chartMax = maxValue > 0 ? (maxValue * 1.2).ceilToDouble() : 5.0;
    final lineCount = 5;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visualización de Afectación',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                Column(
                  children: List.generate(lineCount, (index) {
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: index == lineCount - 1
                                  ? Colors.transparent
                                  : const Color(0xFFE8EEF7),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Positioned.fill(
                  bottom: 28,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: items.map((item) {
                      final barHeight = chartMax > 0
                          ? (item.value / chartMax) * 170
                          : 0.0;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 30,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: item.color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2E6B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF444455),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(lineCount, (index) {
              final valueLabel =
                  ((chartMax / (lineCount - 1)) * (lineCount - 1 - index))
                      .toInt();
              return Expanded(
                child: Text(
                  valueLabel.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9FA3B2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ChartItem {
  final String label;
  final double value;
  final Color color;

  const _ChartItem(this.label, this.value, this.color);
}

// ─── Badge criticidad ───────────────────────────────────────────
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

// ─── Widget cambio de estado ────────────────────────────────────
class _CambiarEstadoWidget extends StatelessWidget {
  final EventModel event;
  final EventController controller;

  const _CambiarEstadoWidget({required this.event, required this.controller});

  static const List<Map<String, dynamic>> _estados = [
    {
      'value': 'abierto',
      'label': 'Abierto',
      'icon': Icons.radio_button_unchecked_rounded,
      'color': Color(0xFF27AE60),
    },
    {
      'value': 'en_proceso',
      'label': 'En proceso',
      'icon': Icons.autorenew_rounded,
      'color': Colors.orange,
    },
    {
      'value': 'en_validacion',
      'label': 'En validación',
      'icon': Icons.fact_check_outlined,
      'color': Colors.blue,
    },
    {
      'value': 'cerrado',
      'label': 'Cerrado',
      'icon': Icons.check_circle_rounded,
      'color': Colors.grey,
    },
  ];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cambiar Estado',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: _estados.map((e) {
              final isSelected = event.estado == e['value'];
              final color = e['color'] as Color;
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (!isSelected) {
                      // No hace Get.back() — la pantalla se actualiza
                      // automáticamente gracias al Obx del padre
                      await controller.updateEstado(
                        event.id,
                        e['value'] as String,
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.15)
                          : const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFFDDDDE8),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          e['icon'] as IconData,
                          color: isSelected ? color : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e['label'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? color : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
