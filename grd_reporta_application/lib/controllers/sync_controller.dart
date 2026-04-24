import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/event_model.dart';
import 'event_controller.dart';

/// Controla la sincronización automática offline→online.
/// Escucha cambios de conectividad y sube los reportes pendientes en Hive.
class SyncController extends GetxController {
  static const String _boxName = 'offline_reports';

  final RxBool isOnline = true.obs;
  final RxInt pendingCount = 0.obs;
  final RxBool isSyncing = false.obs;
  final RxString syncStatus = ''.obs;

  StreamSubscription? _connectivitySub;
  late Box _box;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box(_boxName);
    _updatePendingCount();

    // Escuchar cambios de red
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      final online = result != ConnectivityResult.none;
      isOnline.value = online;
      if (online && pendingCount.value > 0) {
        syncPending();
      }
    });

    // Verificar estado inicial
    final initial = await Connectivity().checkConnectivity();
    isOnline.value = initial != ConnectivityResult.none;

    if (isOnline.value && pendingCount.value > 0) {
      await syncPending();
    }
  }

  /// Guarda un evento en Hive para sincronización posterior
  Future<void> saveOffline(Map<String, dynamic> eventMap) async {
    final key = eventMap['id'] as String;
    await _box.put(key, eventMap);
    _updatePendingCount();
    Get.snackbar(
      'Sin conexión',
      'Reporte guardado localmente. Se sincronizará al recuperar la red.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  /// Sincroniza todos los reportes pendientes con Firestore
  Future<void> syncPending() async {
    if (isSyncing.value || _box.isEmpty) return;
    isSyncing.value = true;
    syncStatus.value = 'Sincronizando ${_box.length} reporte(s)...';

    final eventController = Get.find<EventController>();
    final keys = _box.keys.toList();
    int synced = 0;

    for (final key in keys) {
      try {
        final data = Map<String, dynamic>.from(_box.get(key) as Map);
        final event = EventModel.fromMap(data);

        await eventController.createEventFromModel(event);
        await _box.delete(key);
        synced++;
        syncStatus.value = 'Sincronizando $synced/${keys.length}...';
      } catch (_) {
        // Dejar en cola para el próximo intento
      }
    }

    _updatePendingCount();
    isSyncing.value = false;
    syncStatus.value = '';

    if (synced > 0) {
      Get.snackbar(
        '¡Sincronizado!',
        '$synced reporte(s) enviados al servidor.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _updatePendingCount() {
    pendingCount.value = _box.length;
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }
}
