import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'El servicio de ubicación está desactivado. '
          'Activa el GPS del dispositivo.';
    }

    // 2. Verificar / solicitar permisos
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permiso de ubicación denegado.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Permiso de ubicación denegado permanentemente. '
          'Habilítalo en los ajustes del dispositivo.';
    }

    // 3. Obtener posición
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  /// Formatea lat/lng en texto legible
  static String formatCoords(double lat, double lng) =>
      '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

  /// Retorna URL de Google Maps para las coordenadas
  static String mapsUrl(double lat, double lng) =>
      'https://maps.google.com/?q=$lat,$lng';
}