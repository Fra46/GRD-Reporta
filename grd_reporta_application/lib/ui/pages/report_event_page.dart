import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../../controllers/event_controller.dart';
import '../widgets/report/report_header_widget.dart';
import '../widgets/report/report_stepper_widget.dart';
import '../widgets/report/report_bottom_buttons_widget.dart';
import '../widgets/report/steps/step_datos_basicos_widget.dart';
import '../widgets/report/steps/step_afectacion_widget.dart';
import '../widgets/report/steps/step_accion_widget.dart';
import '../widgets/report/steps/step_fotos_widget.dart';

class ReportEventPage extends StatefulWidget {
  const ReportEventPage({super.key});

  @override
  State<ReportEventPage> createState() => _ReportEventPageState();
}

class _ReportEventPageState extends State<ReportEventPage> {
  final EventController controller = Get.put(EventController());

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();

  int currentStep = 0;

  String? municipioSeleccionado = 'Valledupar';
  String? corregimientoSeleccionado;
  String tipoEvento = 'Vendaval';
  final fechaController = TextEditingController();
  DateTime? fechaSeleccionada;

  final descripcionController = TextEditingController();
  String criticidad = 'baja';
  bool hayAfectacion = false;
  final personasController = TextEditingController();
  final familiasController = TextEditingController();
  final indirectasController = TextEditingController();
  final viviendasAController = TextEditingController();
  final viviendasDController = TextEditingController();
  final hectareasController = TextEditingController();

  final accionController = TextEditingController();
  final observacionController = TextEditingController();
  String? ubicacionGps;
  double? latitud;
  double? longitud;
  bool loadingGps = false;

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
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      });
    }
  }

  Future<void> _obtenerUbicacion() async {
    setState(() => loadingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('GPS desactivado', 'Activa la ubicación del dispositivo',
            snackPosition: SnackPosition.BOTTOM);
        setState(() => loadingGps = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Permiso denegado', 'Se necesita permiso de ubicación',
              snackPosition: SnackPosition.BOTTOM);
          setState(() => loadingGps = false);
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitud = position.latitude;
        longitud = position.longitude;
        ubicacionGps =
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        loadingGps = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'No se pudo obtener la ubicación',
          snackPosition: SnackPosition.BOTTOM);
      setState(() => loadingGps = false);
    }
  }

  Future<void> _agregarFoto() async {
    if (fotos.length >= 4) {
      Get.snackbar('Límite', 'Máximo 4 fotos por reporte',
          snackPosition: SnackPosition.BOTTOM);
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
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF1B2E6B)),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF1B2E6B)),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 75);
      if (picked != null) setState(() => fotos.add(picked));
    }
  }

  Future<void> _guardar() async {
    await controller.createEvent(
      tipoEvento: tipoEvento,
      municipio: municipioSeleccionado ?? 'Valledupar',
      corregimiento: corregimientoSeleccionado ?? '',
      ubicacion: ubicacionGps ?? '',
      descripcion: descripcionController.text,
      criticidad: criticidad,
      hayAfectacion: hayAfectacion,
      observacion: observacionController.text,
      personasAfectadas: int.tryParse(personasController.text) ?? 0,
      familiasAfectadas: int.tryParse(familiasController.text) ?? 0,
      familiasIndirectas: int.tryParse(indirectasController.text) ?? 0,
      viviendasAfectadas: int.tryParse(viviendasAController.text) ?? 0,
      viviendasDestruidas: int.tryParse(viviendasDController.text) ?? 0,
      hectareasAfectadas: double.tryParse(hectareasController.text) ?? 0,
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          const ReportHeaderWidget(),
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
            isLoading: controller.isLoading,
            onNext: _next,
            onBack: _back,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return StepDatosBasicosWidget(
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
          formKey: formKey3,
          accionController: accionController,
          observacionController: observacionController,
          ubicacionGps: ubicacionGps,
          loadingGps: loadingGps,
          onObtenerUbicacion: _obtenerUbicacion,
        );
      case 3:
        return StepFotosWidget(
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
}