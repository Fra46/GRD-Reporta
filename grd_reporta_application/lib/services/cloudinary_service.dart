import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // ─── Configuración Cloudinary ──────────────────────────────────────────
  // Reemplaza estos valores con los de tu cuenta Cloudinary:
  // Dashboard → Settings → Upload → Upload presets (unsigned)
  static const String _cloudName = 'TU_CLOUD_NAME';
  static const String _uploadPreset = 'grd_reporta_unsigned';
  static const String _folder = 'grd_reporta/eventos';

  /// Sube un archivo de imagen a Cloudinary y retorna la URL segura.
  /// [onProgress] recibe un valor de 0.0 a 1.0 con el avance.
  static Future<String> uploadImage(
    File imageFile, {
    String? eventoId,
    void Function(double progress)? onProgress,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = _uploadPreset;
    request.fields['folder'] =
        eventoId != null ? '$_folder/$eventoId' : _folder;
    request.fields['quality'] = 'auto';
    request.fields['fetch_format'] = 'auto';

    final multipartFile = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
    );
    request.files.add(multipartFile);

    onProgress?.call(0.1);

    final streamedResponse = await request.send();

    onProgress?.call(0.8);

    final response = await http.Response.fromStream(streamedResponse);

    onProgress?.call(1.0);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['secure_url'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw 'Error Cloudinary: ${error['error']?['message'] ?? response.statusCode}';
    }
  }

  /// Sube múltiples imágenes en secuencia.
  /// Retorna lista de URLs. Las que fallen devuelven null y se omiten.
  static Future<List<String>> uploadMultiple(
    List<File> files, {
    String? eventoId,
    void Function(int current, int total)? onProgress,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      try {
        onProgress?.call(i, files.length);
        final url = await uploadImage(files[i], eventoId: eventoId);
        urls.add(url);
      } catch (_) {
        // Foto fallida — se omite pero no cancela el resto
      }
    }
    onProgress?.call(files.length, files.length);
    return urls;
  }
}