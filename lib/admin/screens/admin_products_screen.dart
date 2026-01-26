import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/image_upload_widget.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final ProductRepository _productRepo = ProductRepository();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/products'),
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
                                  'Kelola Produk',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tambah, edit, atau hapus produk',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showProductDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Produk'),
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
                        // Search bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari produk...',
                              border: InputBorder.none,
                              icon: Icon(Icons.search, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildProductTable(),
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

  Widget _buildProductTable() {
    return StreamBuilder<List<ProductModel>>(
      stream: _productRepo.getAllProductsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Gagal memuat produk: ${snapshot.error}'),
              ],
            ),
          );
        }

        var products = snapshot.data ?? [];

        // Filter by search
        if (_searchQuery.isNotEmpty) {
          products = products
              .where((p) =>
                  p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  p.category.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
        }

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'Belum ada produk'
                      : 'Produk tidak ditemukan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateColor.resolveWith(
                    (states) => const Color(0xFFF8F9FA)),
                columns: [
                  DataColumn(
                    label: Text('Gambar',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                  DataColumn(
                    label: Text('Nama Produk',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                  DataColumn(
                    label: Text('Kategori',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                  DataColumn(
                    label: Text('Harga',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                  DataColumn(
                    label: Text('Stok',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                  DataColumn(
                    label: Text('Status',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                  DataColumn(
                    label: Text('Aksi',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ],
                rows: products.map((product) {
                  return DataRow(
                    cells: [
                      DataCell(
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(
                                  product.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, size: 24),
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image, size: 24),
                                ),
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.name,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              product.description,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD84A7E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.category,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFD84A7E),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          'Rp ${_formatPrice(product.price)}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${product.stock}',
                          style: GoogleFonts.poppins(
                            color: product.stock < 10
                                ? Colors.red
                                : Colors.black87,
                          ),
                        ),
                      ),
                      DataCell(
                        Switch(
                          value: product.isActive,
                          onChanged: (value) {
                            _productRepo.toggleProductActive(product.id, value);
                          },
                          activeColor: const Color(0xFFD84A7E),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Color(0xFFD84A7E)),
                              onPressed: () =>
                                  _showProductDialog(product: product),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(product),
                              tooltip: 'Hapus',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showProductDialog({ProductModel? product}) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController =
        TextEditingController(text: product?.description ?? '');
    final priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    final stockController =
        TextEditingController(text: product?.stock.toString() ?? '');
    final imageUrlController =
        TextEditingController(text: product?.imageUrl ?? '');
    String category = product?.category ?? 'Sponge Cake';
    bool isActive = product?.isActive ?? true;

    final categories = [
      'Dessert Cakes & Tarts',
      'Cookies & Shortbread',
      'Sponge & Butter Cakes',
      'Sponge Cake',
      'Pastry',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            isEditing ? 'Edit Produk' : 'Tambah Produk',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Produk',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Harga (Rp)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Stok',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => category = value ?? 'Kue');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Image Upload Widget
                  Text(
                    'Gambar Produk',
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
                    folder: 'Home/dapurmamma/products',
                    height: 150,
                    placeholder: 'Upload gambar produk',
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
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Status Aktif', style: GoogleFonts.poppins()),
                    value: isActive,
                    onChanged: (value) => setDialogState(() => isActive = value),
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
              child: Text('Batal',
                  style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama dan harga harus diisi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final price = int.tryParse(priceController.text) ?? 0;
                  final stock = int.tryParse(stockController.text) ?? 0;

                  if (isEditing) {
                    await _productRepo.updateProduct(product.copyWith(
                      name: nameController.text,
                      description: descController.text,
                      price: price,
                      stock: stock,
                      category: category,
                      imageUrl: imageUrlController.text,
                      isActive: isActive,
                      updatedAt: DateTime.now(),
                    ));
                  } else {
                    await _productRepo.createProduct(ProductModel(
                      id: '',
                      productId: '',
                      name: nameController.text,
                      description: descController.text,
                      price: price,
                      stock: stock,
                      category: category,
                      imageUrl: imageUrlController.text,
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

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Produk',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${product.name}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _productRepo.deleteProduct(product.id);
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
