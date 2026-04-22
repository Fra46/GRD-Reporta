import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/event_controller.dart';

import '../widgets/dashboard/dashboard_header_widget.dart';
import '../widgets/dashboard/dashboard_kpi_card.dart';
import '../widgets/dashboard/dashboard_bottom_nav.dart';
import '../widgets/events/event_card_widget.dart';

import 'report_event_page.dart';
import 'event_list_page.dart';
import 'export_report_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final controller = Get.put(DashboardController());
    Get.put(EventController());

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
                        _buildMapPlaceholder(),
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

  Widget _buildMapPlaceholder() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF7),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 180),
            painter: _MapGridPainter(),
          ),
          Positioned(left: 90, top: 60, child: _mapPin(Colors.red)),
          Positioned(left: 180, top: 95, child: _mapPin(Colors.orange)),
          Positioned(left: 130, top: 110, child: _mapPin(Colors.blue)),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white.withOpacity(0.85),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 14, color: Color(0xFF1B2E6B)),
                  SizedBox(width: 4),
                  Text(
                    'Cesar, Colombia — Geolocalización próximamente',
                    style: TextStyle(
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
  }

  Widget _mapPin(Color color) {
    return Column(
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
                color: color.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        Container(width: 2, height: 8, color: color),
      ],
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

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCDD8EC)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final roadPaint = Paint()
      ..color = const Color(0xFFB8C8E0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..cubicTo(
        size.width * 0.3, size.height * 0.3,
        size.width * 0.6, size.height * 0.6,
        size.width, size.height * 0.5,
      );
    canvas.drawPath(path, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..cubicTo(
        size.width * 0.3, size.height * 0.4,
        size.width * 0.4, size.height * 0.6,
        size.width * 0.5, size.height,
      );
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}