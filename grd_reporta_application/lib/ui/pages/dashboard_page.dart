import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';

import '../widgets/dashboard/dashboard_header_widget.dart';
import '../widgets/dashboard/dashboard_kpi_card.dart';
import '../widgets/dashboard/recent_event_item.dart';
import '../widgets/dashboard/dashboard_bottom_nav.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());
    final AuthController auth = Get.find<AuthController>();

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
                        const Text(
                          'Eventos Recientes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildRecentEvents(auth.role),
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
                    child: FloatingActionButton(
                      backgroundColor: Colors.red,
                      onPressed: () {
                        Get.snackbar(
                          'Nuevo Reporte',
                          'Próximamente módulo de eventos',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: const Icon(Icons.add, color: Colors.white),
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
              title: 'Eventos Hoy',
              value: controller.openEvents.value.toString(),
              icon: Icons.calendar_today_rounded,
              iconColor: const Color(0xFF1A6FD4),
              iconBgColor: const Color(0xFFE3EFFD),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DashboardKpiCard(
              title: 'Activos',
              value: controller.criticalEvents.value.toString(),
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
              title: 'Familias',
              value: '957',
              icon: Icons.people_alt_rounded,
              iconColor: const Color(0xFF27AE60),
              iconBgColor: const Color(0xFFE6F9EE),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DashboardKpiCard(
              title: 'Viviendas',
              value: '572',
              icon: Icons.home_rounded,
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
            title: 'Activos',
            value: controller.openEvents.value.toString(),
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.red,
            iconBgColor: const Color(0xFFFFECEC),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: DashboardKpiCard(
            title: 'Pendientes',
            value: controller.pendingEvents.value.toString(),
            icon: Icons.assignment_rounded,
            iconColor: const Color(0xFFF39C12),
            iconBgColor: const Color(0xFFFFF4E0),
          ),
        ),
      ]);
    }

    if (role == 'analista') {
      return Row(children: [
        Expanded(
          child: DashboardKpiCard(
            title: 'Por validar',
            value: controller.pendingEvents.value.toString(),
            icon: Icons.fact_check_rounded,
            iconColor: const Color(0xFF1A6FD4),
            iconBgColor: const Color(0xFFE3EFFD),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: DashboardKpiCard(
            title: 'Críticos',
            value: controller.criticalEvents.value.toString(),
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
          title: 'Eventos mes',
          value: '36',
          icon: Icons.bar_chart_rounded,
          iconColor: const Color(0xFF1B2E6B),
          iconBgColor: const Color(0xFFE8ECF7),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: DashboardKpiCard(
          title: 'Críticos',
          value: controller.criticalEvents.value.toString(),
          icon: Icons.pie_chart_rounded,
          iconColor: Colors.red,
          iconBgColor: const Color(0xFFFFECEC),
        ),
      ),
    ]);
  }

  Widget _buildRecentEvents(String role) {
    if (role == 'admin') {
      return const Column(children: [
        RecentEventItem(title: 'Valledupar', subtitle: 'Incendio Forestal', time: 'Hace 2h', color: Colors.red),
        RecentEventItem(title: 'Pueblo Bello', subtitle: 'Vendaval', time: 'Hace 4h', color: Colors.orange),
        RecentEventItem(title: 'San Diego', subtitle: 'Deslizamiento', time: 'Hace 6h', color: Colors.blue),
      ]);
    }
    if (role == 'coordinador') {
      return const Column(children: [
        RecentEventItem(title: 'Bosconia', subtitle: 'Asignado brigada', time: 'Hace 1h', color: Colors.green),
        RecentEventItem(title: 'La Paz', subtitle: 'Pendiente visita', time: 'Hace 3h', color: Colors.orange),
      ]);
    }
    if (role == 'analista') {
      return const Column(children: [
        RecentEventItem(title: 'Manaure', subtitle: 'EDAN requerido', time: 'Hace 1h', color: Colors.red),
        RecentEventItem(title: 'Agustín Codazzi', subtitle: 'Validación técnica', time: 'Hace 5h', color: Colors.blue),
      ]);
    }
    return const Column(children: [
      RecentEventItem(title: 'Resumen semanal', subtitle: '12 eventos reportados', time: 'Hoy', color: Colors.indigo),
      RecentEventItem(title: 'Municipios críticos', subtitle: 'Valledupar / Bosconia', time: 'Hoy', color: Colors.red),
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