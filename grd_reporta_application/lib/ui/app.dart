import 'package:flutter/material.dart';
import 'package:get/get.dart';

import './pages/login_page.dart';
import '../../controllers/auth_controller.dart';

class GrdReportaApp extends StatelessWidget {
  const GrdReportaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyecta el controlador al iniciar la app
    Get.put(AuthController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GRD Reporta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}