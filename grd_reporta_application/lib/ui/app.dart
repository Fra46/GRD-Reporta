import 'package:flutter/material.dart';
import 'package:get/get.dart';

import './pages/login_page.dart';
import './pages/dashboard_page.dart';
import '../../controllers/auth_controller.dart';

class GrdReportaApp extends StatelessWidget {
  const GrdReportaApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GRD Reporta',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
        ),
        GetPage(
          name: '/dashboard',
          page: () => const DashboardPage(),
        ),
      ],
    );
  }
}