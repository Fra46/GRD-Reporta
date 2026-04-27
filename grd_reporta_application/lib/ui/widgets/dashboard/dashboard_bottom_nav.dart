import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../pages/event_list_page.dart';
import '../../pages/analytics_page.dart';
import '../../pages/profile_page.dart';

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Inicio',
            selected: true,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.warning_amber_rounded,
            label: 'Reportes',
            onTap: () => Get.to(() => const EventListPage()),
          ),
          _NavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Analíticas',
            onTap: () => Get.to(
              () => const AnalyticsPage(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 320),
            ),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Perfil',
            onTap: () => Get.to(() => const ProfilePage()),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1B2E6B) : const Color(0xFF9999AA);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
