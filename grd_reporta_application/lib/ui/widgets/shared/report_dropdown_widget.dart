import 'package:flutter/material.dart';
import 'report_field_deco.dart';

class ReportDropdownWidget<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String hint;
  final IconData icon;
  final void Function(T?) onChanged;
  final bool required;

  const ReportDropdownWidget({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: reportFieldDeco(hint, icon),
      isExpanded: true,
      items: items
          .map((i) => DropdownMenuItem<T>(
                value: i,
                child: Text(i.toString(),
                    overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: onChanged,
      validator: required ? (v) => v == null ? 'Seleccione una opción' : null : null,
    );
  }
}