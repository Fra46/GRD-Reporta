import 'package:flutter/material.dart';

class GpsFieldWidget extends StatelessWidget {
  final String? ubicacionGps;
  final bool loadingGps;
  final VoidCallback onObtenerUbicacion;

  const GpsFieldWidget({
    super.key,
    required this.ubicacionGps,
    required this.loadingGps,
    required this.onObtenerUbicacion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ubicacionGps != null
              ? const Color(0xFF2ECC71)
              : const Color(0xFFDDDDE8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ubicacionGps != null
                ? Icons.location_on_rounded
                : Icons.location_off_rounded,
            color: ubicacionGps != null
                ? const Color(0xFF2ECC71)
                : Colors.grey,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ubicacionGps ?? 'Sin ubicación capturada',
              style: TextStyle(
                color: ubicacionGps != null
                    ? const Color(0xFF1A1A2E)
                    : Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: loadingGps ? null : onObtenerUbicacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2E6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: loadingGps
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      ubicacionGps != null ? 'Actualizar' : 'Obtener GPS',
                      style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}