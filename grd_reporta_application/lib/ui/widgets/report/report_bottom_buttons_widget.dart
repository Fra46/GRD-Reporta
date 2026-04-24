import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportBottomButtonsWidget extends StatelessWidget {
  final int currentStep;
  final bool isEditing;
  final RxBool isLoading;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ReportBottomButtonsWidget({
    super.key,
    required this.currentStep,
    this.isEditing = false,
    required this.isLoading,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Row(
          children: [
            if (currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1B2E6B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Atrás',
                    style: TextStyle(
                      color: Color(0xFF1B2E6B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: Obx(
                () => ElevatedButton(
                  onPressed: isLoading.value ? null : onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentStep == 3
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFF1B2E6B),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFF1B2E6B,
                    ).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          currentStep == 3
                              ? (isEditing
                                    ? 'Guardar cambios'
                                    : 'Enviar Reporte')
                              : 'Continuar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
