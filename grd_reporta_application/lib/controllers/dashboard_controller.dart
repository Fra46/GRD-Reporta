import 'package:get/get.dart';

import 'event_controller.dart';

class DashboardController
    extends GetxController {
  final EventController events =
      Get.find<EventController>();

  RxBool isLoading =
      true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void>
      loadDashboard() async {
    isLoading.value = true;

    await events.loadEvents();

    isLoading.value =
        false;
  }

  int get totalEventos =>
      events.totalEventos;

  int get totalCriticos =>
      events.totalCriticos;

  int get totalConAfectacion =>
      events.totalConAfectacion;

  int get totalEdan =>
      events.totalEdan;

  int get totalAbiertos =>
      events.totalAbiertos;

  get recientes =>
      events.events.take(5).toList();
}