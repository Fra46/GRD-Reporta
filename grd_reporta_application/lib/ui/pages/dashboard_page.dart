import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/event_controller.dart';

import '../widgets/dashboard/dashboard_header_widget.dart';
import '../widgets/dashboard/dashboard_kpi_card.dart';
import '../widgets/dashboard/dashboard_bottom_nav.dart';
import '../widgets/events/event_card_widget.dart';

import '../widgets/events/event_map_widget.dart';
import 'report_event_page.dart';
import 'event_list_page.dart';
import 'export_report_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          const DashboardHeaderWidget(),
          Expanded(
            child: Stack(
              children: [
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return RefreshIndicator(
                    onRefresh: controller.loadDashboard,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                      children: [
                        _buildKpiSection(auth.role, controller),
                        const SizedBox(height: 28),
                        const Text(
                          'Mapa de Eventos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const EventMapWidget(),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Eventos Recientes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.to(() => const EventListPage()),
                              child: const Text(
                                'Ver todos',
                                style: TextStyle(color: Color(0xFF1B2E6B)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          final eventController = Get.find<EventController>();
                          return Column(
                            children: eventController.events
                                .take(3)
                                .map((e) => EventCardWidget(event: e))
                                .toList(),
                          );
                        }),
                        const SizedBox(height: 140),
                      ],
                    ),
                  );
                }),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: const DashboardBottomNav(),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 90,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'fab_export',
                          backgroundColor: const Color(0xFF1B2E6B),
                          onPressed: () => Get.to(() => const ExportReportPage()),
                          child: const Icon(Icons.download, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          heroTag: 'fab_report',
                          backgroundColor: Colors.red,
                          onPressed: () => Get.to(() => const ReportEventPage()),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSection(String role, DashboardController controller) {
    if (role == 'admin') {
      return Column(children: [
        Row(children: [
          Expanded(
            child: DashboardKpiCard(
              title: 'Eventos',
              value: controller.totalEventos.toString(),
              icon: Icons.list_alt_rounded,
              iconColor: const Color(0xFF1A6FD4),
              iconBgColor: const Color(0xFFE3EFFD),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DashboardKpiCard(
              title: 'Críticos',
              value: controller.totalCriticos.toString(),
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.red,
              iconBgColor: const Color(0xFFFFECEC),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: DashboardKpiCard(
              title: 'Afectación',
              value: controller.totalConAfectacion.toString(),
              icon: Icons.people_alt_rounded,
              iconColor: const Color(0xFF27AE60),
              iconBgColor: const Color(0xFFE6F9EE),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DashboardKpiCard(
              title: 'EDAN',
              value: controller.totalEdan.toString(),
              icon: Icons.fact_check_rounded,
              iconColor: const Color(0xFF16A085),
              iconBgColor: const Color(0xFFE0F7F4),
            ),
          ),
        ]),
      ]);
    }

    if (role == 'coordinador') {
      return Row(children: [
        Expanded(
          child: DashboardKpiCard(
            title: 'Eventos',
            value: controller.totalEventos.toString(),
            icon: Icons.list_alt_rounded,
            iconColor: const Color(0xFF1A6FD4),
            iconBgColor: const Color(0xFFE3EFFD),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: DashboardKpiCard(
            title: 'Críticos',
            value: controller.totalCriticos.toString(),
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.red,
            iconBgColor: const Color(0xFFFFECEC),
          ),
        ),
      ]);
    }

    if (role == 'analista') {
      return Row(children: [
        Expanded(
          child: DashboardKpiCard(
            title: 'EDAN',
            value: controller.totalEdan.toString(),
            icon: Icons.fact_check_rounded,
            iconColor: const Color(0xFF1A6FD4),
            iconBgColor: const Color(0xFFE3EFFD),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: DashboardKpiCard(
            title: 'Críticos',
            value: controller.totalCriticos.toString(),
            icon: Icons.analytics_rounded,
            iconColor: Colors.red,
            iconBgColor: const Color(0xFFFFECEC),
          ),
        ),
      ]);
    }

    return Row(children: [
      Expanded(
        child: DashboardKpiCard(
          title: 'Eventos',
          value: controller.totalEventos.toString(),
          icon: Icons.bar_chart_rounded,
          iconColor: const Color(0xFF1B2E6B),
          iconBgColor: const Color(0xFFE8ECF7),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: DashboardKpiCard(
          title: 'Críticos',
          value: controller.totalCriticos.toString(),
          icon: Icons.pie_chart_rounded,
          iconColor: Colors.red,
          iconBgColor: const Color(0xFFFFECEC),
        ),
      ),
    ]);
  }
}