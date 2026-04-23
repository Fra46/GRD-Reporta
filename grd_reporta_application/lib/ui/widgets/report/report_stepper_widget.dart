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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: List.generate(_steps.length, (i) {
          final isDone = i < currentStep;
          final isCurrent = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 40,
                        height: 40,
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
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 20)
                              : Icon(
                                  _icons[i],
                                  size: 18,
                                  color: isCurrent
                                      ? const Color(0xFF1B2E6B)
                                      : Colors.white.withOpacity(0.7),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _steps[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isCurrent
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 28),
                      color: i < currentStep
                          ? const Color(0xFF2ECC71)
                          : Colors.white.withOpacity(0.25),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}