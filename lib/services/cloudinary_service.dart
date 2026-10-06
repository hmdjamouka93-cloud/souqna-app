import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'fnlnwhhg';
  static const String _uploadPreset = 'souqna_unsigned';

  /// يرفع صورة ويجيب URL
  /// [file] = الملف
  /// يرجّع URL الصورة المرفوعة
  static Future<String?> uploadImage(File file) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        return data['secure_url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// يرفع عدة صور مرة وحدة
  /// يرجّع List من URLs (بلا nulls)
  static Future<List<String>> uploadImages(List<File> files) async {
    final urls = <String>[];
    for (final f in files) {
      final url = await uploadImage(f);
      if (url != null) urls.add(url);
    }
    return urls;
  }
}
