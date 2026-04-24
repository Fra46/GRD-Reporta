import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/event_model.dart';
import 'auth_controller.dart';

class EventController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthController auth = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxList<EventModel> events = <EventModel>[].obs;

  final Uuid uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  // =====================================
  // CREAR EVENTO REAL
  // =====================================

  Future<void> createEvent({
    required String tipoEvento,
    required String municipio,
    required String descripcion,
    required String criticidad,
    required bool hayAfectacion,
    String corregimiento = '',
    String ubicacion = '',
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
  }) async {
    try {
      isLoading.value = true;

      final bool requiereEdan = hayAfectacion;
      final bool escaladoCmgrd = hayAfectacion;

      final event = EventModel(
        id: uuid.v4(),
        municipio: municipio,
        corregimiento: corregimiento,
        ubicacion: ubicacion,
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
        requiereEdan: requiereEdan,
        escaladoCmgrd: escaladoCmgrd,
        apoyoUngrd: apoyoUngrd,
        apoyoDepartamento: apoyoDepartamento,
        apoyoMunicipio: apoyoMunicipio,
        estado: 'abierto',
        observacion: observacion,
        usuarioId: auth.uid,
        usuarioNombre: auth.name,
      );

      await _db.collection('events').doc(event.id).set(event.toMap());

      Get.snackbar(
        'Éxito',
        'Evento registrado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadEvents();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No fue posible registrar el evento',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
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
      Get.snackbar('Error', 'No fue posible cargar eventos');
    } finally {
      isLoading.value = false;
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
  // KPIs DASHBOARD
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