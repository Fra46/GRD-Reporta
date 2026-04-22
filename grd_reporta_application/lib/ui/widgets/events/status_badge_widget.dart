import 'package:flutter/material.dart';

class StatusBadgeWidget
    extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadgeWidget({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(
      BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withOpacity(
                .12),
        borderRadius:
            BorderRadius.circular(
                30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight:
              FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}