import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/event_controller.dart';
import '../../utils/constants.dart';

/// Widget reutilizable para agregar fotos a un evento ya guardado.
/// Se usa en EventDetailPage para adjuntar evidencia posterior al registro.
class EvidencePickerWidget extends StatefulWidget {
  final String eventId;

  const EvidencePickerWidget({super.key, required this.eventId});

  @override
  State<EvidencePickerWidget> createState() => _EvidencePickerWidgetState();
}

class _EvidencePickerWidgetState extends State<EvidencePickerWidget> {
  final EventController controller = Get.find<EventController>();
  final ImagePicker _picker = ImagePicker();

  Future<void> _agregarFoto() async {
    // Obtener el evento actual para saber cuántas fotos tiene
    final event = controller.events.firstWhereOrNull(
      (e) => e.id == widget.eventId,
    );
    if (event == null) return;

    if (event.fotosUrls.length >= AppConstants.maxFotosPorEvento) {
      Get.snackbar(
        'Límite alcanzado',
        'Este evento ya tiene ${AppConstants.maxFotosPorEvento} fotos',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Mostrar selector cámara / galería
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
              leading: const Icon(Icons.camera_alt_rounded,
                  color: Color(0xFF1B2E6B)),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: Color(0xFF1B2E6B)),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: AppConstants.imageQuality,
      maxWidth: AppConstants.imageMaxWidth.toDouble(),
    );
    if (picked == null) return;

    await controller.addFotoToEvent(
      eventId: widget.eventId,
      foto: File(picked.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final event = controller.events.firstWhereOrNull(
        (e) => e.id == widget.eventId,
      );
      if (event == null) return const SizedBox.shrink();

      final canAdd = event.fotosUrls.length < AppConstants.maxFotosPorEvento;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evidencia fotográfica (${event.fotosUrls.length}/'
                '${AppConstants.maxFotosPorEvento})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              if (canAdd)
                TextButton.icon(
                  onPressed: _agregarFoto,
                  icon: const Icon(Icons.add_photo_alternate_outlined,
                      size: 18),
                  label: const Text('Agregar'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1B2E6B),
                  ),
                ),
            ],
          ),
          if (event.fotosUrls.isEmpty)
            GestureDetector(
              onTap: _agregarFoto,
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFDDDDE8),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          color: Color(0xFF9999AA), size: 28),
                      SizedBox(height: 6),
                      Text(
                        'Sin fotos — toca para agregar',
                        style: TextStyle(
                            color: Color(0xFF9999AA), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: event.fotosUrls.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      event.fotosUrls[i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: 100, height: 100,
                          color: const Color(0xFFE8EEF7),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}