import 'package:flutter/material.dart';

class ReportStepperWidget extends StatelessWidget {
  final int currentStep;

  const ReportStepperWidget({super.key, required this.currentStep});

  static const _steps = ['Datos\nBásicos', 'Afectación', 'Acción', 'Fotos'];
  static const _icons = [
    Icons.info_outline_rounded,
    Icons.people_outline_rounded,
    Icons.assignment_outlined,
    Icons.camera_alt_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1B2E6B),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            final isDone = stepIndex < currentStep;
            final isCurrent = stepIndex == currentStep;
            return Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF2ECC71)
                          : isCurrent
                          ? Colors.white
                          : Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 22,
                            )
                          : Icon(
                              _icons[stepIndex],
                              size: 20,
                              color: isCurrent
                                  ? const Color(0xFF1B2E6B)
                                  : Colors.white.withOpacity(0.75),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _steps[stepIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isCurrent
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            );
          }

          final lineIndex = index ~/ 2;
          final isActive = lineIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 22),
              color: isActive
                  ? const Color(0xFF2ECC71)
                  : Colors.white.withOpacity(0.25),
            ),
          );
        }),
      ),
    );
  }
}
