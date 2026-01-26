import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Service untuk upload gambar ke Cloudinary
/// 
/// SETUP:
/// 1. Login ke https://cloudinary.com/console
/// 2. Buat Upload Preset (Settings > Upload > Upload presets > Add upload preset)
///    - Signing Mode: Unsigned
///    - Folder: Home/dapurmamma (sesuaikan)
///    - Klik Save
/// 3. Copy Cloud Name dari Dashboard
/// 4. Ganti nilai di bawah ini
class CloudinaryService {
  // ============================================
  // GANTI DENGAN KREDENSIAL CLOUDINARY ANDA
  // ============================================
  static const String cloudName = 'dwpngs3hc'; // Contoh: 'dxyz123abc'
  static const String uploadPreset = 'FlutterDapurMamma'; // Contoh: 'dapurmamma_unsigned'
  static const String defaultFolder = 'Home/dapurmamma';
  // ============================================

  static String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Upload gambar dari bytes (untuk Web)
  /// Returns URL gambar yang diupload atau null jika gagal
  static Future<CloudinaryUploadResult?> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    String? folder,
  }) async {
    try {
      final uri = Uri.parse(_uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      // Tambahkan file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

      // Tambahkan parameter
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder ?? defaultFolder;

      // Kirim request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CloudinaryUploadResult(
          success: true,
          url: data['secure_url'] as String,
          publicId: data['public_id'] as String,
          width: data['width'] as int?,
          height: data['height'] as int?,
        );
      } else {
        final error = json.decode(response.body);
        return CloudinaryUploadResult(
          success: false,
          error: error['error']?['message'] ?? 'Upload gagal',
        );
      }
    } catch (e) {
      return CloudinaryUploadResult(
        success: false,
        error: 'Error: $e',
      );
    }
  }

  /// Hapus gambar dari Cloudinary (memerlukan signed request)
  /// Untuk sekarang, hapus manual dari Cloudinary Console
  static Future<bool> deleteImage(String publicId) async {
    // Untuk delete perlu API secret (backend)
    // Implementasi via Cloud Function jika diperlukan
    return false;
  }

  /// Generate URL dengan transformasi (resize, crop, dll)
  static String getTransformedUrl(
    String originalUrl, {
    int? width,
    int? height,
    String? crop,
    String? quality,
  }) {
    if (!originalUrl.contains('cloudinary.com')) {
      return originalUrl;
    }

    // Parse URL dan tambahkan transformasi
    final transformations = <String>[];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (crop != null) transformations.add('c_$crop');
    if (quality != null) transformations.add('q_$quality');

    if (transformations.isEmpty) return originalUrl;

    // Insert transformasi sebelum /v1/ atau /upload/
    final transformStr = transformations.join(',');
    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/$transformStr/',
    );
  }

  /// URL untuk thumbnail
  static String getThumbnailUrl(String originalUrl,
      {int size = 150}) {
    return getTransformedUrl(
      originalUrl,
      width: size,
      height: size,
      crop: 'fill',
      quality: 'auto',
    );
  }

  /// URL untuk banner (landscape)
  static String getBannerUrl(String originalUrl,
      {int width = 800, int height = 400}) {
    return getTransformedUrl(
      originalUrl,
      width: width,
      height: height,
      crop: 'fill',
      quality: 'auto',
    );
  }
}

/// Hasil upload ke Cloudinary
class CloudinaryUploadResult {
  final bool success;
  final String? url;
  final String? publicId;
  final int? width;
  final int? height;
  final String? error;

  CloudinaryUploadResult({
    required this.success,
    this.url,
    this.publicId,
    this.width,
    this.height,
    this.error,
  });
}
