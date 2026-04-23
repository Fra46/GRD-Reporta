import 'package:flutter/material.dart';

class ReportResumenWidget extends StatelessWidget {
  final String municipio;
  final String corregimiento;
  final String tipoEvento;
  final String fecha;
  final String criticidad;
  final bool hayAfectacion;
  final String? ubicacionGps;
  final int cantidadFotos;

  const ReportResumenWidget({
    super.key,
    required this.municipio,
    required this.corregimiento,
    required this.tipoEvento,
    required this.fecha,
    required this.criticidad,
    required this.hayAfectacion,
    required this.ubicacionGps,
    required this.cantidadFotos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF1B2E6B).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.summarize_rounded,
                color: Color(0xFF1B2E6B), size: 18),
            SizedBox(width: 8),
            Text('Resumen del reporte',
                style: TextStyle(
                    color: Color(0xFF1B2E6B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          _Fila('Municipio', municipio),
          _Fila('Corregimiento', corregimiento.isEmpty ? '-' : corregimiento),
          _Fila('Tipo', tipoEvento),
          _Fila('Fecha', fecha.isEmpty ? '-' : fecha),
          _Fila('Criticidad', criticidad.toUpperCase()),
          _Fila('Afectación', hayAfectacion ? 'Sí' : 'No'),
          _Fila('GPS', ubicacionGps ?? 'No capturado'),
          _Fila('Fotos', '$cantidadFotos adjuntas'),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final String label;
  final String value;
  const _Fila(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF555567), fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Color(0xFF1B2E6B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}