import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../controllers/event_controller.dart';
import 'event_detail_page.dart';

/// Página para escanear QR de eventos GRD-REPORTA.
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _scanned = false;
  final MobileScannerController _ctrl = MobileScannerController();

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null || !raw.startsWith('GRD-REPORTA:')) return;

    _scanned = true;
    _ctrl.stop();

    // Extraer ID
    final parts = raw.split('|');
    final id = parts.first.replaceFirst('GRD-REPORTA:', '').trim();

    // Buscar evento en el controller
    final ec = Get.find<EventController>();
    final idx = ec.events.indexWhere((e) => e.id == id);

    if (idx != -1) {
      Get.off(() => EventDetailPage(eventId: id));
    } else {
      // Mostrar datos del QR si el evento no está cargado
      _showQrInfo(parts);
    }
  }

  void _showQrInfo(List<String> parts) {
    final info = parts.skip(1).map((p) {
      final kv = p.split(':');
      return '${kv.first}: ${kv.length > 1 ? kv.sublist(1).join(':') : ''}';
    }).join('\n');

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Evento GRD escaneado'),
        content: Text(info),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              setState(() => _scanned = false);
              _ctrl.start();
            },
            child: const Text('Escanear otro'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2E6B),
            ),
            onPressed: () => Get.back(),
            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),
          // Overlay UI
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const Expanded(
                        child: Text(
                          'Escanear QR de Evento',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flash_on_rounded,
                            color: Colors.white),
                        onPressed: () => _ctrl.toggleTorch(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Marco de escaneo
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF1B2E6B), width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Apunta al código QR del evento GRD',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}