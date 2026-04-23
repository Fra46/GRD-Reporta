import 'package:flutter/material.dart';
import '../../shared/report_field_deco.dart';
import '../../shared/gps_field_widget.dart';

class StepAccionWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController accionController;
  final TextEditingController observacionController;
  final String? ubicacionGps;
  final bool loadingGps;
  final VoidCallback onObtenerUbicacion;

  const StepAccionWidget({
    super.key,
    required this.formKey,
    required this.accionController,
    required this.observacionController,
    required this.ubicacionGps,
    required this.loadingGps,
    required this.onObtenerUbicacion,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Acción Tomada'),
          const SizedBox(height: 16),
          const _Label('Acción Tomada'),
          const SizedBox(height: 8),
          TextFormField(
            controller: accionController,
            maxLines: 4,
            decoration: reportFieldDeco(
                'Describa la acción tomada...', Icons.assignment_outlined),
            validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),
          const _Label('Observaciones adicionales'),
          const SizedBox(height: 8),
          TextFormField(
            controller: observacionController,
            maxLines: 3,
            decoration:
                reportFieldDeco('Observaciones...', Icons.note_outlined),
          ),
          const SizedBox(height: 16),
          const _Label('Ubicación GPS'),
          const SizedBox(height: 8),
          GpsFieldWidget(
            ubicacionGps: ubicacionGps,
            loadingGps: loadingGps,
            onObtenerUbicacion: onObtenerUbicacion,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)));
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555567)));
}