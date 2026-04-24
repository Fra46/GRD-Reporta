import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/sync_controller.dart';

/// Badge flotante que muestra el estado de sincronización.
/// Aparece en el header del dashboard.
class SyncIndicatorWidget extends StatelessWidget {
  const SyncIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = Get.find<SyncController>();

    return Obx(() {
      final isOnline = sync.isOnline.value;
      final pending = sync.pendingCount.value;
      final syncing = sync.isSyncing.value;

      if (isOnline && pending == 0 && !syncing) return const SizedBox.shrink();

      Color bgColor;
      IconData icon;
      String label;

      if (syncing) {
        bgColor = Colors.blue;
        icon = Icons.sync_rounded;
        label = sync.syncStatus.value.isNotEmpty
            ? sync.syncStatus.value
            : 'Sincronizando...';
      } else if (!isOnline && pending > 0) {
        bgColor = Colors.orange;
        icon = Icons.cloud_off_rounded;
        label = '$pending pendiente(s)';
      } else if (!isOnline) {
        bgColor = Colors.orange;
        icon = Icons.wifi_off_rounded;
        label = 'Sin conexión';
      } else {
        bgColor = Colors.green;
        icon = Icons.cloud_upload_rounded;
        label = 'Sincronizando...';
      }

      return GestureDetector(
        onTap: isOnline && pending > 0 ? sync.syncPending : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bgColor.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              syncing
                  ? SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: bgColor,
                      ),
                    )
                  : Icon(icon, color: bgColor, size: 13),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: bgColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}