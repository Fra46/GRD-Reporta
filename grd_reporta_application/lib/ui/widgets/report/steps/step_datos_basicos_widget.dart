import 'package:flutter/material.dart';
import 'package:grd_reporta_application/ui/widgets/shared/report_field_deco.dart';
import 'package:grd_reporta_application/ui/widgets/shared/report_dropdown_widget.dart';

class StepDatosBasicosWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String? municipioSeleccionado;
  final String? corregimientoSeleccionado;
  final String tipoEvento;
  final TextEditingController fechaController;
  final void Function(String?) onMunicipioChanged;
  final void Function(String?) onCorregimientoChanged;
  final void Function(String?) onTipoChanged;
  final VoidCallback onPickFecha;

  static const List<String> _corregimientos = [
    'Agustín Codazzi', 'Astrea', 'Becerril', 'Bosconia', 'Chimichagua',
    'Chiriguaná', 'Curumaní', 'El Copey', 'El Paso', 'Gamarra',
    'González', 'La Gloria', 'La Jagua de Ibirico', 'La Paz', 'Manaure',
    'Pailitas', 'Pelaya', 'Pueblo Bello', 'Río de Oro', 'San Alberto',
    'San Diego', 'San Martín', 'Tamalameque', 'Valledupar', 'Venezuela',
  ];

  static const List<String> _tiposEvento = [
    'Vendaval', 'Inundación', 'Deslizamiento', 'Incendio Forestal',
    'Incendio Estructural', 'Sismo', 'Granizada', 'Sequía',
    'Accidente de Tránsito', 'Otro',
  ];

  const StepDatosBasicosWidget({
    super.key,
    required this.formKey,
    required this.municipioSeleccionado,
    required this.corregimientoSeleccionado,
    required this.tipoEvento,
    required this.fechaController,
    required this.onMunicipioChanged,
    required this.onCorregimientoChanged,
    required this.onTipoChanged,
    required this.onPickFecha,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Datos del Evento'),
          const SizedBox(height: 16),
          const _Label('Municipio'),
          const SizedBox(height: 8),
          ReportDropdownWidget<String>(
            value: municipioSeleccionado,
            items: const ['Valledupar'],
            hint: 'Municipio',
            icon: Icons.location_city_rounded,
            onChanged: onMunicipioChanged,
          ),
          const SizedBox(height: 16),
          const _Label('Corregimiento / Vereda'),
          const SizedBox(height: 8),
          ReportDropdownWidget<String>(
            value: corregimientoSeleccionado,
            items: _corregimientos,
            hint: 'Seleccionar corregimiento',
            icon: Icons.map_outlined,
            onChanged: onCorregimientoChanged,
          ),
          const SizedBox(height: 16),
          const _Label('Tipo de Evento'),
          const SizedBox(height: 8),
          ReportDropdownWidget<String>(
            value: tipoEvento,
            items: _tiposEvento,
            hint: 'Tipo de evento',
            icon: Icons.warning_amber_rounded,
            onChanged: onTipoChanged,
            required: true,
          ),
          const SizedBox(height: 16),
          const _Label('Fecha del Evento'),
          const SizedBox(height: 8),
          TextFormField(
            controller: fechaController,
            readOnly: true,
            onTap: onPickFecha,
            decoration: reportFieldDeco('Seleccionar fecha',
                Icons.calendar_today_rounded),
            validator: (v) =>
                v == null || v.isEmpty ? 'Seleccione la fecha' : null,
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
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E)));
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF555567)));
}