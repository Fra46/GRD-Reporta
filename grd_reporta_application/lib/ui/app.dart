import 'package:flutter/material.dart';
import 'package:get/get.dart';

import './pages/login_page.dart';
import './pages/dashboard_page.dart';
import './pages/splash_page.dart';
import './pages/analytics_page.dart';
import './pages/onboarding_page.dart';
import './pages/profile_page.dart';
import './pages/heatmap_page.dart';
import './pages/qr_scanner_page.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../controllers/analytics_controller.dart';
import 'theme.dart';

class GrdReportaApp extends StatelessWidget {
  const GrdReportaApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    Get.put(EventController());
    Get.put(SyncController());
    Get.put(AnalyticsController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GRD Reporta',
      theme: AppTheme.lightTheme(),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 320),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: '/onboarding', page: () => const OnboardingPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/dashboard', page: () => const DashboardPage()),
        GetPage(name: '/analytics', page: () => const AnalyticsPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/heatmap', page: () => const HeatmapPage()),
        GetPage(name: '/qr_scanner', page: () => const QrScannerPage()),
      ],
    );
  }
}
