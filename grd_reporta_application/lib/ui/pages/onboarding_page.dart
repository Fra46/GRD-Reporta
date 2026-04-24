import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme.dart';
import '../widgets/shared/app_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.camera_alt_outlined,
      'title': 'Captura en el campo',
      'description':
          'Toma fotos, genera QR y registra eventos con GPS aunque no haya internet.',
      'color': AppColors.secondary,
    },
    {
      'icon': Icons.notifications_active_outlined,
      'title': 'Siempre alerta',
      'description':
          'Recibe notificaciones de eventos críticos y cambios de estado al instante.',
      'color': AppColors.success,
    },
    {
      'icon': Icons.analytics_outlined,
      'title': 'Datos que importan',
      'description':
          'Visualiza KPIs reales, tendencias y exporta reportes en PDF.',
      'color': AppColors.primary,
    },
  ];

  void _completeOnboarding() {
    final box = Hive.box('settings');
    box.put('seen_onboarding', true);
    Get.offAllNamed('/login');
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _completeOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Omitir'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: page['color']!.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 88,
                            color: page['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Comenzar ahora'
                        : 'Siguiente',
                    onPressed: _nextPage,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text('Ya conozco la app'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
