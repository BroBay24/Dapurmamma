import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/cloudinary_service.dart';

/// Widget untuk upload gambar ke Cloudinary
/// Digunakan di admin panel untuk upload banner dan produk
class ImageUploadWidget extends StatefulWidget {
  final String? currentImageUrl;
  final ValueChanged<String> onImageUploaded;
  final String folder;
  final double height;
  final double? width;
  final String placeholder;
  final BoxFit fit;

  const ImageUploadWidget({
    super.key,
    this.currentImageUrl,
    required this.onImageUploaded,
    this.folder = 'Home/dapurmamma',
    this.height = 200,
    this.width,
    this.placeholder = 'Klik untuk upload gambar',
    this.fit = BoxFit.cover,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  bool _isUploading = false;
  String? _imageUrl;
  String? _errorMessage;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.currentImageUrl;
  }

  @override
  void didUpdateWidget(ImageUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentImageUrl != oldWidget.currentImageUrl) {
      setState(() {
        _imageUrl = widget.currentImageUrl;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Baca bytes
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _selectedImageBytes = bytes;
        _isUploading = true;
        _errorMessage = null;
      });

      // Upload ke Cloudinary
      final result = await CloudinaryService.uploadImage(
        imageBytes: bytes,
        fileName: pickedFile.name,
        folder: widget.folder,
      );

      if (result != null && result.success && result.url != null) {
        setState(() {
          _imageUrl = result.url;
          _isUploading = false;
        });
        widget.onImageUploaded(result.url!);
      } else {
        setState(() {
          _isUploading = false;
          _errorMessage = result?.error ?? 'Upload gagal';
          _selectedImageBytes = null;
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Error: $e';
        _selectedImageBytes = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _isUploading ? null : _pickAndUploadImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _errorMessage != null
                    ? Colors.red.withOpacity(0.5)
                    : Colors.grey[300]!,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildContent(),
            ),
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        if (_imageUrl != null && _imageUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Gambar berhasil diupload',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickAndUploadImage,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Ganti'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD84A7E),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    // Sedang upload
    if (_isUploading) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (_selectedImageBytes != null)
            Opacity(
              opacity: 0.5,
              child: Image.memory(
                _selectedImageBytes!,
                fit: widget.fit,
              ),
            ),
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 12),
                Text(
                  'Mengupload...',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Ada gambar
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _imageUrl!,
            fit: widget.fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFFD84A7E),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _buildPlaceholder(isError: true),
          ),
          // Overlay hover effect
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickAndUploadImage,
                child: Container(
                  color: Colors.black.withOpacity(0),
                  child: const Center(
                    child: Opacity(
                      opacity: 0,
                      child: Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder({bool isError = false}) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.broken_image : Icons.cloud_upload_outlined,
            size: 48,
            color: isError ? Colors.red[300] : Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            isError ? 'Gagal memuat gambar' : widget.placeholder,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'JPG, PNG, WebP (max 10MB)',
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
