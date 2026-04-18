import 'package:get/get.dart';

class DashboardController extends GetxController {
  RxBool isLoading = true.obs;

  RxInt openEvents = 0.obs;
  RxInt criticalEvents = 0.obs;
  RxInt pendingEvents = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;

      await Future.delayed(const Duration(seconds: 1));

      // Datos temporales simulados
      openEvents.value = 12;
      criticalEvents.value = 5;
      pendingEvents.value = 7;
    } finally {
      isLoading.value = false;
    }
  }
}