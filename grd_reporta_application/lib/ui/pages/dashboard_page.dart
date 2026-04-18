import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import 'login_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final DashboardController dashboardController =
        Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard GRD Reporta'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await authController.logout();
              Get.offAll(() => const LoginPage());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: dashboardController.loadDashboard,
        child: Obx(
          () {
            if (dashboardController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 4),

                Text(
                  authController.currentUser?.email ?? '',
                  style: TextStyle(color: Colors.grey.shade700),
                ),

                const SizedBox(height: 24),

                _DashboardCard(
                  title: 'Eventos abiertos',
                  value:
                      dashboardController.openEvents.value.toString(),
                  icon: Icons.warning_amber_rounded,
                ),

                const SizedBox(height: 16),

                _DashboardCard(
                  title: 'Eventos críticos',
                  value:
                      dashboardController.criticalEvents.value.toString(),
                  icon: Icons.priority_high,
                ),

                const SizedBox(height: 16),

                _DashboardCard(
                  title: 'Pendientes validación',
                  value:
                      dashboardController.pendingEvents.value.toString(),
                  icon: Icons.fact_check_outlined,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, size: 42),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}