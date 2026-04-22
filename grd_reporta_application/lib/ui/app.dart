import 'package:flutter/material.dart';
import 'package:get/get.dart';

import './pages/login_page.dart';
import './pages/dashboard_page.dart';
import './pages/splash_page.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';

class GrdReportaApp extends StatelessWidget {
  const GrdReportaApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    Get.put(EventController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GRD Reporta',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),

      initialRoute: '/splash',

      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/dashboard', page: () => const DashboardPage()),
      ],
    );
  }
}
