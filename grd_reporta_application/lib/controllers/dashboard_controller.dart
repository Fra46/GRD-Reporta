import 'package:get/get.dart';
import 'event_controller.dart';

class DashboardController extends GetxController {
  RxBool isLoading = true.obs;

  EventController get _ec => Get.find<EventController>();

  // Getters que usa DashboardPage
  int get totalEventos => _ec.totalEventos;
  int get totalCriticos => _ec.totalCriticos;
  int get totalConAfectacion => _ec.totalConAfectacion;
  int get totalEdan => _ec.totalEdan;
  int get totalAbiertos => _ec.totalAbiertos;
  int get totalEnProceso => _ec.totalEnProceso;
  int get totalFamilias => _ec.totalFamilias;
  int get totalViviendas => _ec.totalViviendas;

  // Aliases usados por versiones anteriores del dashboard
  int get openEvents => _ec.totalAbiertos;
  int get criticalEvents => _ec.totalCriticos;
  int get pendingEvents => _ec.totalEnProceso;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      await _ec.loadEvents();
    } finally {
      isLoading.value = false;
    }
  }
}