import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../services/location_service.dart';
import '../widgets/report/report_header_widget.dart';
import '../widgets/report/report_stepper_widget.dart';
import '../widgets/report/report_bottom_buttons_widget.dart';
import '../widgets/report/steps/step_datos_basicos_widget.dart';
import '../widgets/report/steps/step_afectacion_widget.dart';
import '../widgets/report/steps/step_accion_widget.dart';
import '../widgets/report/steps/step_fotos_widget.dart';

class ReportEventPage extends StatefulWidget {
  final EventModel? existingEvent;

  const ReportEventPage({super.key, this.existingEvent});

  @override
  State<ReportEventPage> createState() => _ReportEventPageState();
}

class _ReportEventPageState extends State<ReportEventPage> {
  final EventController controller = Get.find<EventController>();

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();

  int currentStep = 0;

  // Step 1 — Datos básicos
  String? municipioSeleccionado;
  String? corregimientoSeleccionado;
  String tipoEvento = 'Vendaval';
  final fechaController = TextEditingController();
  DateTime? fechaSeleccionada;

  // Step 2 — Afectación
  final descripcionController = TextEditingController();
  String criticidad = 'baja';
  bool hayAfectacion = false;
  final personasController = TextEditingController();
  final familiasController = TextEditingController();
  final indirectasController = TextEditingController();
  final viviendasAController = TextEditingController();
  final viviendasDController = TextEditingController();
  final hectareasController = TextEditingController();

  // Step 3 — Acción + GPS
  final accionController = TextEditingController();
  final observacionController = TextEditingController();
  String? ubicacionGps;
  double? latitud;
  double? longitud;
  bool loadingGps = false;

  // Step 4 — Fotos
  final List<XFile> fotos = [];
  final ImagePicker picker = ImagePicker();

  @override
  void dispose() {
    fechaController.dispose();
    descripcionController.dispose();
    personasController.dispose();
    familiasController.dispose();
    indirectasController.dispose();
    viviendasAController.dispose();
    viviendasDController.dispose();
    hectareasController.dispose();
    accionController.dispose();
    observacionController.dispose();
    super.dispose();
  }

  // ─── Fecha ────────────────────────────────────────────────────
  Future<void> _pickFecha() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1B2E6B)),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() {
        fechaSeleccionada = date;
        fechaController.text =
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';
      });
    }
  }

  // ─── GPS ──────────────────────────────────────────────────────
  Future<void> _obtenerUbicacion() async {
    setState(() => loadingGps = true);
    try {
      final position = await LocationService.getCurrentPosition();
      setState(() {
        latitud = position.latitude;
        longitud = position.longitude;
        ubicacionGps = LocationService.formatCoords(
          position.latitude,
          position.longitude,
        );
      });
    } catch (e) {
      Get.snackbar(
        'Error GPS',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => loadingGps = false);
    }
  }

  // ─── Fotos ────────────────────────────────────────────────────
  Future<void> _agregarFoto() async {
    if (fotos.length >= 4) {
      Get.snackbar(
        'Límite',
        'Máximo 4 fotos por reporte',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFF1B2E6B),
              ),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: Color(0xFF1B2E6B),
              ),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1920,
      );
      if (picked != null) setState(() => fotos.add(picked));
    }
  }

  // ─── Guardar ──────────────────────────────────────────────────
  Future<void> _guardar() async {
    final existing = widget.existingEvent;
    if (existing == null) {
      await controller.createEvent(
        tipoEvento: tipoEvento,
        municipio: municipioSeleccionado ?? 'Valledupar',
        corregimiento: corregimientoSeleccionado ?? '',
        ubicacion: ubicacionGps ?? '',
        latitud: latitud,
        longitud: longitud,
        descripcion: descripcionController.text,
        criticidad: criticidad,
        hayAfectacion: hayAfectacion,
        fechaEvento: fechaSeleccionada,
        accionTomada: accionController.text,
        observacion: observacionController.text,
        personasAfectadas: int.tryParse(personasController.text) ?? 0,
        familiasAfectadas: int.tryParse(familiasController.text) ?? 0,
        familiasIndirectas: int.tryParse(indirectasController.text) ?? 0,
        viviendasAfectadas: int.tryParse(viviendasAController.text) ?? 0,
        viviendasDestruidas: int.tryParse(viviendasDController.text) ?? 0,
        hectareasAfectadas: double.tryParse(hectareasController.text) ?? 0,
        fotos: fotos.map((f) => File(f.path)).toList(),
      );
    } else {
      await controller.updateEvent(
        eventId: existing.id,
        tipoEvento: tipoEvento,
        municipio: municipioSeleccionado ?? 'Valledupar',
        corregimiento: corregimientoSeleccionado ?? '',
        ubicacion: ubicacionGps ?? '',
        latitud: latitud,
        longitud: longitud,
        descripcion: descripcionController.text,
        criticidad: criticidad,
        hayAfectacion: hayAfectacion,
        accionTomada: accionController.text,
        observacion: observacionController.text,
        personasAfectadas: int.tryParse(personasController.text) ?? 0,
        familiasAfectadas: int.tryParse(familiasController.text) ?? 0,
        familiasIndirectas: int.tryParse(indirectasController.text) ?? 0,
        viviendasAfectadas: int.tryParse(viviendasAController.text) ?? 0,
        viviendasDestruidas: int.tryParse(viviendasDController.text) ?? 0,
        hectareasAfectadas: double.tryParse(hectareasController.text) ?? 0,
        fechaEvento: fechaSeleccionada ?? existing.fechaEvento,
      );
    }

    Get.back();
  }

  void _next() {
    if (currentStep == 0 && !formKey1.currentState!.validate()) return;
    if (currentStep == 1 && !formKey2.currentState!.validate()) return;
    if (currentStep == 2 && !formKey3.currentState!.validate()) return;
    if (currentStep < 3) {
      setState(() => currentStep++);
    } else {
      _guardar();
    }
  }

  void _back() {
    if (currentStep > 0) setState(() => currentStep--);
  }

  @override
  void initState() {
    super.initState();

    final existing = widget.existingEvent;
    if (existing != null) {
      municipioSeleccionado = existing.municipio;
      corregimientoSeleccionado = existing.corregimiento;
      tipoEvento = existing.tipoEvento;
      fechaSeleccionada = existing.fechaEvento;
      fechaController.text = _formatDate(existing.fechaEvento);
      descripcionController.text = existing.descripcion;
      criticidad = existing.criticidad;
      hayAfectacion = existing.hayAfectacion;
      personasController.text = existing.personasAfectadas.toString();
      familiasController.text = existing.familiasAfectadas.toString();
      indirectasController.text = existing.familiasIndirectas.toString();
      viviendasAController.text = existing.viviendasAfectadas.toString();
      viviendasDController.text = existing.viviendasDestruidas.toString();
      hectareasController.text = existing.hectareasAfectadas.toString();
      accionController.text = existing.accionTomada;
      observacionController.text = existing.observacion;
      ubicacionGps = existing.ubicacion;
      latitud = existing.latitud;
      longitud = existing.longitud;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          Column(
            children: [
              ReportHeaderWidget(
                title: widget.existingEvent == null
                    ? 'Nuevo Reporte'
                    : 'Editar Reporte',
              ),
              ReportStepperWidget(currentStep: currentStep),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCurrentStep(),
                  ),
                ),
              ),
              ReportBottomButtonsWidget(
                currentStep: currentStep,
                isEditing: widget.existingEvent != null,
                isLoading: controller.isLoading,
                onNext: _next,
                onBack: _back,
              ),
            ],
          ),

          // Overlay de upload de fotos
          Obx(() {
            if (!controller.isUploading.value) {
              return const SizedBox.shrink();
            }
            return Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_upload_rounded,
                        size: 48,
                        color: Color(0xFF1B2E6B),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Subiendo evidencia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Text(
                          controller.uploadStatus.value,
                          style: const TextStyle(
                            color: Color(0xFF888899),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: controller.uploadProgress.value,
                            backgroundColor: const Color(0xFFE8ECF7),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF1B2E6B),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return StepDatosBasicosWidget(
          key: const ValueKey(0),
          formKey: formKey1,
          municipioSeleccionado: municipioSeleccionado,
          corregimientoSeleccionado: corregimientoSeleccionado,
          tipoEvento: tipoEvento,
          fechaController: fechaController,
          onMunicipioChanged: (v) => setState(() => municipioSeleccionado = v),
          onCorregimientoChanged: (v) =>
              setState(() => corregimientoSeleccionado = v),
          onTipoChanged: (v) => setState(() => tipoEvento = v!),
          onPickFecha: _pickFecha,
        );
      case 1:
        return StepAfectacionWidget(
          key: const ValueKey(1),
          formKey: formKey2,
          descripcionController: descripcionController,
          criticidad: criticidad,
          hayAfectacion: hayAfectacion,
          personasController: personasController,
          familiasController: familiasController,
          indirectasController: indirectasController,
          viviendasAController: viviendasAController,
          viviendasDController: viviendasDController,
          hectareasController: hectareasController,
          onCriticidadChanged: (v) => setState(() => criticidad = v),
          onAfectacionChanged: (v) => setState(() => hayAfectacion = v),
        );
      case 2:
        return StepAccionWidget(
          key: const ValueKey(2),
          formKey: formKey3,
          accionController: accionController,
          observacionController: observacionController,
          ubicacionGps: ubicacionGps,
          latitud: latitud,
          longitud: longitud,
          loadingGps: loadingGps,
          onObtenerUbicacion: _obtenerUbicacion,
        );
      case 3:
        return StepFotosWidget(
          key: const ValueKey(3),
          fotos: fotos,
          municipio: municipioSeleccionado ?? 'Valledupar',
          corregimiento: corregimientoSeleccionado ?? '-',
          tipoEvento: tipoEvento,
          fecha: fechaController.text,
          criticidad: criticidad,
          hayAfectacion: hayAfectacion,
          ubicacionGps: ubicacionGps,
          onAgregarFoto: _agregarFoto,
          onEliminarFoto: (f) => setState(() => fotos.remove(f)),
        );
      default:
        return const SizedBox();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
