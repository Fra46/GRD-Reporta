import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../controllers/auth_controller.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    final settings = Hive.box('settings');
    final hasSeenOnboarding =
        settings.get('seen_onboarding', defaultValue: false) as bool;

    if (!hasSeenOnboarding) {
      Get.offAll(() => const OnboardingPage());
      return;
    }

    if (authController.firebaseUser.value == null) {
      Get.offAll(() => const LoginPage());
    } else {
      Get.offAll(() => const DashboardPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset('assets/images/ungrd_logo.jpg', height: 80),
            ),

            const SizedBox(height: 20),

            const Text(
              'GRD Reporta',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Sistema de Reportes de Emergencias · Cesar',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
