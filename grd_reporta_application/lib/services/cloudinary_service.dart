import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class CloudinaryService {
  static String get _cloudName => AppConstants.cloudinaryCloudName;
  static String get _preset => AppConstants.cloudinaryUploadPreset;
  static String get _folder => AppConstants.cloudinaryFolder;

  static Future<String> uploadImage(
    File imageFile, {
    String? eventoId,
    void Function(double progress)? onProgress,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = _preset;
    request.fields['folder'] = eventoId != null
        ? '$_folder/$eventoId'
        : _folder;
    request.fields['quality'] = 'auto';
    request.fields['fetch_format'] = 'auto';

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    onProgress?.call(0.1);
    final streamed = await request.send();
    onProgress?.call(0.8);
    final response = await http.Response.fromStream(streamed);
    onProgress?.call(1.0);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['secure_url'] as String;
    }

    final error = jsonDecode(response.body);
    throw 'Error Cloudinary: '
        '${error['error']?['message'] ?? response.statusCode}';
  }

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
      } catch (_) {}
    }
    onProgress?.call(files.length, files.length);
    return urls;
  }

  static bool get isConfigured => _cloudName.isNotEmpty;
}
