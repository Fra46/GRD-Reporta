import 'package:flutter/material.dart';

class CriticidadSelectorWidget extends StatelessWidget {
  final String criticidad;
  final void Function(String) onChanged;

  const CriticidadSelectorWidget({
    super.key,
    required this.criticidad,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['baja', 'media', 'alta'].map((c) {
        final isSelected = criticidad == c;
        final color = c == 'alta'
            ? Colors.red
            : c == 'media'
                ? Colors.orange
                : const Color(0xFF2ECC71);

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: c != 'alta' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : const Color(0xFFDDDDE8),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    c == 'alta'
                        ? Icons.arrow_upward_rounded
                        : c == 'media'
                            ? Icons.remove_rounded
                            : Icons.arrow_downward_rounded,
                    color: isSelected ? Colors.white : color,
                    size: 18,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c[0].toUpperCase() + c.substring(1),
                    style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}