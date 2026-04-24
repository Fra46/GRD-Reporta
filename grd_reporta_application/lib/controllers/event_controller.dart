import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/event_model.dart';
import '../services/cloudinary_service.dart';
import 'auth_controller.dart';

class EventController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthController auth = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxString uploadStatus = ''.obs;

  final RxList<EventModel> events = <EventModel>[].obs;

  final Uuid uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  // =====================================
  // CREAR EVENTO REAL + FOTOS
  // =====================================

  Future<void> createEvent({
    required String tipoEvento,
    required String municipio,
    required String descripcion,
    required String criticidad,
    required bool hayAfectacion,
    String corregimiento = '',
    String ubicacion = '',
    double? latitud,
    double? longitud,
    String observacion = '',
    String accionTomada = '',
    int personasAfectadas = 0,
    int familiasAfectadas = 0,
    int familiasIndirectas = 0,
    int viviendasAfectadas = 0,
    int viviendasDestruidas = 0,
    double hectareasAfectadas = 0,
    bool apoyoUngrd = false,
    bool apoyoDepartamento = false,
    bool apoyoMunicipio = false,
    List<File> fotos = const [],
  }) async {
    try {
      isLoading.value = true;

      final String eventoId = uuid.v4();
      List<String> fotosUrls = [];

      // Subir fotos si las hay
      if (fotos.isNotEmpty) {
        isUploading.value = true;
        uploadStatus.value = 'Subiendo foto 1 de ${fotos.length}...';
        uploadProgress.value = 0;

        fotosUrls = await CloudinaryService.uploadMultiple(
          fotos,
          eventoId: eventoId,
          onProgress: (current, total) {
            uploadProgress.value =
                total > 0 ? current / total : 0;
            if (current < total) {
              uploadStatus.value =
                  'Subiendo foto ${current + 1} de $total...';
            } else {
              uploadStatus.value = 'Finalizando...';
            }
          },
        );

        isUploading.value = false;
        uploadStatus.value = '';
      }

      final event = EventModel(
        id: eventoId,
        municipio: municipio,
        corregimiento: corregimiento,
        ubicacion: ubicacion,
        latitud: latitud,
        longitud: longitud,
        tipoEvento: tipoEvento,
        descripcion: descripcion,
        criticidad: criticidad,
        fechaEvento: DateTime.now(),
        fechaRegistro: DateTime.now(),
        hayAfectacion: hayAfectacion,
        personasAfectadas: personasAfectadas,
        familiasAfectadas: familiasAfectadas,
        familiasIndirectas: familiasIndirectas,
        viviendasAfectadas: viviendasAfectadas,
        viviendasDestruidas: viviendasDestruidas,
        hectareasAfectadas: hectareasAfectadas,
        accionTomada: accionTomada,
        requiereEdan: hayAfectacion,
        escaladoCmgrd: hayAfectacion,
        apoyoUngrd: apoyoUngrd,
        apoyoDepartamento: apoyoDepartamento,
        apoyoMunicipio: apoyoMunicipio,
        estado: 'abierto',
        observacion: observacion,
        fotosUrls: fotosUrls,
        usuarioId: auth.uid,
        usuarioNombre: auth.name,
      );

      await _db.collection('events').doc(eventoId).set(event.toMap());

      Get.snackbar(
        'Éxito',
        fotos.isNotEmpty
            ? 'Evento registrado con ${fotosUrls.length} foto(s)'
            : 'Evento registrado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadEvents();
    } catch (e) {
      isUploading.value = false;
      Get.snackbar(
        'Error',
        'No fue posible registrar el evento: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isUploading.value = false;
      uploadProgress.value = 0;
      uploadStatus.value = '';
    }
  }

  // =====================================
  // LISTAR EVENTOS
  // =====================================

  Future<void> loadEvents() async {
    try {
      isLoading.value = true;

      final snapshot = await _db
          .collection('events')
          .orderBy('fechaRegistro', descending: true)
          .get();

      final data = snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList();

      events.assignAll(data);
    } catch (_) {
      Get.snackbar('Error', 'No fue posible cargar los eventos');
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================
  // AGREGAR FOTO A EVENTO EXISTENTE
  // =====================================

  Future<void> addFotoToEvent({
    required String eventId,
    required File foto,
  }) async {
    try {
      isUploading.value = true;
      uploadStatus.value = 'Subiendo foto...';
      uploadProgress.value = 0;

      final url = await CloudinaryService.uploadImage(
        foto,
        eventoId: eventId,
        onProgress: (p) => uploadProgress.value = p,
      );

      // Actualizar Firestore con arrayUnion
      await _db.collection('events').doc(eventId).update({
        'fotosUrls': FieldValue.arrayUnion([url]),
      });

      // Actualizar lista local
      final idx = events.indexWhere((e) => e.id == eventId);
      if (idx != -1) {
        final nuevasFotos = [...events[idx].fotosUrls, url];
        events[idx] = events[idx].copyWith(fotosUrls: nuevasFotos);
        events.refresh();
      }

      Get.snackbar('Foto agregada', 'Evidencia guardada correctamente',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo subir la foto',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0;
      uploadStatus.value = '';
    }
  }

  // =====================================
  // CAMBIAR ESTADO
  // =====================================

  Future<void> updateEstado(String eventId, String nuevoEstado) async {
    try {
      await _db.collection('events').doc(eventId).update({
        'estado': nuevoEstado,
      });

      final idx = events.indexWhere((e) => e.id == eventId);
      if (idx != -1) {
        events[idx] = events[idx].copyWith(estado: nuevoEstado);
        events.refresh();
      }

      Get.snackbar(
        'Estado actualizado',
        'Evento marcado como: $nuevoEstado',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar('Error', 'No se pudo actualizar el estado');
    }
  }

  // =====================================
  // KPIs
  // =====================================

  int get totalEventos => events.length;
  int get totalCriticos =>
      events.where((e) => e.criticidad == 'alta').length;
  int get totalConAfectacion =>
      events.where((e) => e.hayAfectacion).length;
  int get totalEdan =>
      events.where((e) => e.requiereEdan).length;
  int get totalAbiertos =>
      events.where((e) => e.estado == 'abierto').length;
  int get totalEnProceso =>
      events.where((e) => e.estado == 'en_proceso').length;
  int get totalCerrados =>
      events.where((e) => e.estado == 'cerrado').length;
  int get totalFamilias =>
      events.fold(0, (sum, e) => sum + e.familiasAfectadas);
  int get totalViviendas =>
      events.fold(0, (sum, e) => sum + e.viviendasAfectadas);
}