import 'package:flutter/material.dart';
import 'package:grd_reporta_application/ui/widgets/shared/report_field_deco.dart';
import 'package:grd_reporta_application/ui/widgets/shared/criticidad_selector_widget.dart';

class StepAfectacionWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController descripcionController;
  final String criticidad;
  final bool hayAfectacion;
  final TextEditingController personasController;
  final TextEditingController familiasController;
  final TextEditingController indirectasController;
  final TextEditingController viviendasAController;
  final TextEditingController viviendasDController;
  final TextEditingController hectareasController;
  final void Function(String) onCriticidadChanged;
  final void Function(bool) onAfectacionChanged;

  const StepAfectacionWidget({
    super.key,
    required this.formKey,
    required this.descripcionController,
    required this.criticidad,
    required this.hayAfectacion,
    required this.personasController,
    required this.familiasController,
    required this.indirectasController,
    required this.viviendasAController,
    required this.viviendasDController,
    required this.hectareasController,
    required this.onCriticidadChanged,
    required this.onAfectacionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Descripción de la Afectación'),
          const SizedBox(height: 16),
          const _Label('Descripción de Afectación'),
          const SizedBox(height: 8),
          TextFormField(
            controller: descripcionController,
            maxLines: 4,
            decoration: reportFieldDeco(
                'Describa lo ocurrido...', Icons.description_outlined),
            validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),
          const _Label('Criticidad'),
          const SizedBox(height: 8),
          CriticidadSelectorWidget(
            criticidad: criticidad,
            onChanged: onCriticidadChanged,
          ),
          const SizedBox(height: 16),
          _AfectacionSwitch(
            value: hayAfectacion,
            onChanged: onAfectacionChanged,
          ),
          if (hayAfectacion) ...[
            const SizedBox(height: 16),
            const _SectionTitle('Datos de Afectación'),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _NumField(personasController, 'Personas', Icons.person_outline)),
              const SizedBox(width: 12),
              Expanded(child: _NumField(familiasController, 'Familias', Icons.people_outline)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _NumField(indirectasController, 'Indirectas', Icons.group_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _NumField(viviendasAController, 'Viv. afect.', Icons.home_outlined)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _NumField(viviendasDController, 'Viv. dest.', Icons.house_siding_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _NumField(hectareasController, 'Hectáreas', Icons.landscape_outlined)),
            ]),
          ],
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _NumField(this.controller, this.label, this.icon);

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: reportFieldDeco(label, icon),
      );
}

class _AfectacionSwitch extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;

  const _AfectacionSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDDDE8)),
      ),
      child: SwitchListTile(
        value: value,
        title: const Text('¿Hay afectación a personas o bienes?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        activeThumbColor: const Color(0xFF1B2E6B),
        onChanged: onChanged,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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