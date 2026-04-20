import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';

import '../widgets/dashboard/dashboard_header_widget.dart';
import '../widgets/dashboard/dashboard_kpi_card.dart';
import '../widgets/dashboard/recent_event_item.dart';
import '../widgets/dashboard/dashboard_bottom_nav.dart';
import '../widgets/dashboard/role_button_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller =
        Get.put(DashboardController());

    final AuthController auth =
        Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          Get.snackbar(
            'Nuevo Reporte',
            'Próximamente módulo de eventos',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: const DashboardBottomNav(),

      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadDashboard,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const DashboardHeaderWidget(),

                const SizedBox(height: 22),

                _buildKpiSection(
                  auth.role,
                  controller,
                ),

                const SizedBox(height: 28),

                const Text(
                  'Módulos disponibles',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                _buildRoleModules(auth.role),

                const SizedBox(height: 28),

                const Text(
                  'Eventos recientes',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                _buildRecentEvents(auth.role),

                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKpiSection(
    String role,
    DashboardController controller,
  ) {
    // ADMIN
    if (role == 'admin') {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DashboardKpiCard(
                  title: 'Abiertos',
                  value:
                      controller.openEvents.value.toString(),
                  icon: Icons.warning_amber_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: DashboardKpiCard(
                  title: 'Críticos',
                  value: controller
                      .criticalEvents.value
                      .toString(),
                  icon: Icons.priority_high,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DashboardKpiCard(
                  title: 'Pendientes',
                  value: controller
                      .pendingEvents.value
                      .toString(),
                  icon: Icons.fact_check_outlined,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: DashboardKpiCard(
                  title: 'Usuarios',
                  value: '14',
                  icon: Icons.people,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // COORDINADOR
    if (role == 'coordinador') {
      return Row(
        children: [
          Expanded(
            child: DashboardKpiCard(
              title: 'Activos',
              value:
                  controller.openEvents.value.toString(),
              icon: Icons.warning,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DashboardKpiCard(
              title: 'Pendientes',
              value: controller
                  .pendingEvents.value
                  .toString(),
              icon: Icons.assignment,
            ),
          ),
        ],
      );
    }

    // ANALISTA
    if (role == 'analista') {
      return Row(
        children: [
          Expanded(
            child: DashboardKpiCard(
              title: 'Por validar',
              value:
                  controller.pendingEvents.value.toString(),
              icon: Icons.fact_check,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DashboardKpiCard(
              title: 'Críticos',
              value: controller
                  .criticalEvents.value
                  .toString(),
              icon: Icons.analytics,
            ),
          ),
        ],
      );
    }

    // DIRECTIVO
    return Row(
      children: [
        Expanded(
          child: DashboardKpiCard(
            title: 'Eventos mes',
            value: '36',
            icon: Icons.bar_chart,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: DashboardKpiCard(
            title: 'Críticos',
            value:
                controller.criticalEvents.value.toString(),
            icon: Icons.pie_chart,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleModules(String role) {
    if (role == 'admin') {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: const [
          RoleButtonWidget(
            title: 'Usuarios',
            icon: Icons.people,
          ),
          RoleButtonWidget(
            title: 'Config.',
            icon: Icons.settings,
          ),
          RoleButtonWidget(
            title: 'Reportes',
            icon: Icons.description,
          ),
          RoleButtonWidget(
            title: 'Dashboard',
            icon: Icons.bar_chart,
          ),
        ],
      );
    }

    if (role == 'coordinador') {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: const [
          RoleButtonWidget(
            title: 'Eventos',
            icon: Icons.warning,
          ),
          RoleButtonWidget(
            title: 'Asignar',
            icon: Icons.assignment_ind,
          ),
          RoleButtonWidget(
            title: 'Seguimiento',
            icon: Icons.track_changes,
          ),
        ],
      );
    }

    if (role == 'analista') {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: const [
          RoleButtonWidget(
            title: 'Validación',
            icon: Icons.fact_check,
          ),
          RoleButtonWidget(
            title: 'EDAN',
            icon: Icons.analytics,
          ),
          RoleButtonWidget(
            title: 'Reportes',
            icon: Icons.description,
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        RoleButtonWidget(
          title: 'Indicadores',
          icon: Icons.bar_chart,
        ),
        RoleButtonWidget(
          title: 'Mapa Riesgo',
          icon: Icons.map,
        ),
        RoleButtonWidget(
          title: 'Resumen',
          icon: Icons.pie_chart,
        ),
      ],
    );
  }

  Widget _buildRecentEvents(String role) {
    if (role == 'admin') {
      return const Column(
        children: [
          RecentEventItem(
            title: 'Valledupar',
            subtitle: 'Incendio Forestal',
            time: 'Hace 2h',
            color: Colors.red,
          ),
          RecentEventItem(
            title: 'Pueblo Bello',
            subtitle: 'Vendaval',
            time: 'Hace 4h',
            color: Colors.orange,
          ),
          RecentEventItem(
            title: 'San Diego',
            subtitle: 'Deslizamiento',
            time: 'Hace 6h',
            color: Colors.blue,
          ),
        ],
      );
    }

    if (role == 'coordinador') {
      return const Column(
        children: [
          RecentEventItem(
            title: 'Bosconia',
            subtitle: 'Asignado brigada',
            time: 'Hace 1h',
            color: Colors.green,
          ),
          RecentEventItem(
            title: 'La Paz',
            subtitle: 'Pendiente visita',
            time: 'Hace 3h',
            color: Colors.orange,
          ),
        ],
      );
    }

    if (role == 'analista') {
      return const Column(
        children: [
          RecentEventItem(
            title: 'Manaure',
            subtitle: 'EDAN requerido',
            time: 'Hace 1h',
            color: Colors.red,
          ),
          RecentEventItem(
            title: 'Agustín Codazzi',
            subtitle: 'Validación técnica',
            time: 'Hace 5h',
            color: Colors.blue,
          ),
        ],
      );
    }

    return const Column(
      children: [
        RecentEventItem(
          title: 'Resumen semanal',
          subtitle: '12 eventos reportados',
          time: 'Hoy',
          color: Colors.indigo,
        ),
        RecentEventItem(
          title: 'Municipios críticos',
          subtitle: 'Valledupar / Bosconia',
          time: 'Hoy',
          color: Colors.red,
        ),
      ],
    );
  }
}