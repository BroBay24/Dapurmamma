import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/banner_model.dart';
import '../../data/repositories/banner_repository.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/image_upload_widget.dart';

class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  final BannerRepository _bannerRepo = BannerRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/banners'),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kelola Banner',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Banner akan tampil di halaman utama aplikasi',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showBannerDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Banner'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD84A7E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildBannerList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Spacer(),
          CircleAvatar(
            backgroundColor: const Color(0xFFD84A7E).withOpacity(0.1),
            child: const Icon(Icons.person, color: Color(0xFFD84A7E)),
          ),
          const SizedBox(width: 8),
          Text(
            'Admin',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerList() {
    return StreamBuilder<List<BannerModel>>(
      stream: _bannerRepo.getAllBannersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat banner',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                Text(
                  '${snapshot.error}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final banners = snapshot.data ?? [];

        if (banners.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined,
                    size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada banner',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tambahkan banner untuk ditampilkan di aplikasi',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: banners.length,
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex--;
            final reordered = List<BannerModel>.from(banners);
            final item = reordered.removeAt(oldIndex);
            reordered.insert(newIndex, item);
            await _bannerRepo.reorderBanners(reordered);
          },
          itemBuilder: (context, index) {
            final banner = banners[index];
            return _buildBannerCard(banner, key: ValueKey(banner.id));
          },
        );
      },
    );
  }

  Widget _buildBannerCard(BannerModel banner, {Key? key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Drag handle
            const Icon(Icons.drag_handle, color: Colors.grey),
            const SizedBox(width: 16),
            // Banner image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: banner.imageUrl.isNotEmpty
                  ? Image.network(
                      banner.imageUrl,
                      width: 160,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 160,
                        height: 90,
                        color: Colors.grey[200],
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 160,
                      height: 90,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16),
            // Banner info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Urutan: ${banner.order + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (banner.linkUrl != null && banner.linkUrl!.isNotEmpty)
                    Text(
                      'Link: ${banner.linkUrl}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: banner.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                banner.isActive ? 'Aktif' : 'Nonaktif',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: banner.isActive ? Colors.green : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Actions
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFD84A7E)),
              onPressed: () => _showBannerDialog(banner: banner),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(
                banner.isActive ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () async {
                await _bannerRepo.toggleBannerActive(banner.id, !banner.isActive);
              },
              tooltip: banner.isActive ? 'Nonaktifkan' : 'Aktifkan',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(banner),
              tooltip: 'Hapus',
            ),
          ],
        ),
      ),
    );
  }

  void _showBannerDialog({BannerModel? banner}) {
    final isEditing = banner != null;
    final titleController = TextEditingController(text: banner?.title ?? '');
    final imageUrlController =
        TextEditingController(text: banner?.imageUrl ?? '');
    final linkUrlController =
        TextEditingController(text: banner?.linkUrl ?? '');
    bool isActive = banner?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            isEditing ? 'Edit Banner' : 'Tambah Banner',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Judul Banner',
                      hintText: 'Contoh: Promo Lebaran',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Image Upload Widget
                  Text(
                    'Gambar Banner',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ImageUploadWidget(
                    currentImageUrl: imageUrlController.text.isNotEmpty
                        ? imageUrlController.text
                        : null,
                    onImageUploaded: (url) {
                      setDialogState(() {
                        imageUrlController.text = url;
                      });
                    },
                    folder: 'Home/dapurmamma/banners',
                    height: 180,
                    placeholder: 'Upload gambar banner',
                  ),
                  const SizedBox(height: 8),
                  // Manual URL input (opsional)
                  ExpansionTile(
                    title: Text(
                      'Atau masukkan URL manual',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(top: 8),
                    children: [
                      TextField(
                        controller: imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'URL Gambar',
                          hintText: 'https://res.cloudinary.com/...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: linkUrlController,
                    decoration: InputDecoration(
                      labelText: 'URL Tujuan (Opsional)',
                      hintText: 'https://example.com/promo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(
                      'Status Aktif',
                      style: GoogleFonts.poppins(),
                    ),
                    value: isActive,
                    onChanged: (value) {
                      setDialogState(() => isActive = value);
                    },
                    activeColor: const Color(0xFFD84A7E),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    imageUrlController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul dan URL gambar harus diisi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  if (isEditing) {
                    await _bannerRepo.updateBanner(banner.copyWith(
                      title: titleController.text,
                      imageUrl: imageUrlController.text,
                      linkUrl: linkUrlController.text,
                      isActive: isActive,
                      updatedAt: DateTime.now(),
                    ));
                  } else {
                    await _bannerRepo.createBanner(BannerModel(
                      id: '',
                      title: titleController.text,
                      imageUrl: imageUrlController.text,
                      linkUrl: linkUrlController.text,
                      order: 999, // Will be reordered
                      isActive: isActive,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ));
                  }
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menyimpan: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD84A7E),
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BannerModel banner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Banner',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus banner "${banner.title}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _bannerRepo.deleteBanner(banner.id);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
