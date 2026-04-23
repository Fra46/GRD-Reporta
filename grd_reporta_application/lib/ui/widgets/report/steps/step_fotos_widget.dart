import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/report_resumen_widget.dart';

class StepFotosWidget extends StatelessWidget {
  final List<XFile> fotos;
  final String municipio;
  final String corregimiento;
  final String tipoEvento;
  final String fecha;
  final String criticidad;
  final bool hayAfectacion;
  final String? ubicacionGps;
  final VoidCallback onAgregarFoto;
  final void Function(XFile) onEliminarFoto;

  const StepFotosWidget({
    super.key,
    required this.fotos,
    required this.municipio,
    required this.corregimiento,
    required this.tipoEvento,
    required this.fecha,
    required this.criticidad,
    required this.hayAfectacion,
    required this.ubicacionGps,
    required this.onAgregarFoto,
    required this.onEliminarFoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Evidencia Fotográfica',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E))),
        const SizedBox(height: 8),
        Text(
          'Agrega hasta 4 fotos del evento (opcional)',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            ...fotos.map((f) => _FotoCard(foto: f, onEliminar: onEliminarFoto)),
            if (fotos.length < 4) _AddFotoCard(onTap: onAgregarFoto),
          ],
        ),
        const SizedBox(height: 24),
        ReportResumenWidget(
          municipio: municipio,
          corregimiento: corregimiento,
          tipoEvento: tipoEvento,
          fecha: fecha,
          criticidad: criticidad,
          hayAfectacion: hayAfectacion,
          ubicacionGps: ubicacionGps,
          cantidadFotos: fotos.length,
        ),
      ],
    );
  }
}

class _FotoCard extends StatelessWidget {
  final XFile foto;
  final void Function(XFile) onEliminar;

  const _FotoCard({required this.foto, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(foto.path),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => onEliminar(foto),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddFotoCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFotoCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDDDE8)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 36, color: Color(0xFF1B2E6B)),
            SizedBox(height: 8),
            Text('Agregar foto',
                style: TextStyle(
                    color: Color(0xFF1B2E6B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}