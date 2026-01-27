import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/banner_repository.dart';
import '../../data/models/product_model.dart';
import '../../data/models/banner_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final OrderRepository _orderRepo;
  late final ProductRepository _productRepo;
  late final BannerRepository _bannerRepo;
  Map<String, int>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _orderRepo = OrderRepository();
    _productRepo = ProductRepository();
    _bannerRepo = BannerRepository();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _orderRepo.getOrderStatistics();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(context),
          // Main Content
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
                        Text(
                          'Dashboard',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selamat datang di Panel Admin Dapur Mamma',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildStatsGrid(),
                        const SizedBox(height: 32),
                        _buildRecentProductsSection(),
                        const SizedBox(height: 32),
                        _buildRecentBannersSection(),
                        const SizedBox(height: 32),
                        _buildQuickActions(),
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

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFFD84A7E),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/icons/DapurMamma.png',
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cake, color: Colors.white, size: 40),
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: true,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.inventory_2,
                  label: 'Produk',
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/admin/products'),
                ),
                _buildNavItem(
                  icon: Icons.photo_library,
                  label: 'Banner',
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/admin/banners'),
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag,
                  label: 'Pesanan',
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/admin/orders'),
                ),
              ],
            ),
          ),
          // Logout
          const Divider(color: Colors.white24, height: 1),
          _buildNavItem(
            icon: Icons.home,
            label: 'Lihat Aplikasi',
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/admin/login',
                      (route) => false,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Keluar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadStats();
            },
          ),
          const SizedBox(width: 16),
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

  Widget _buildStatsGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              title: 'Total Pesanan',
              value: '${_stats?['totalOrders'] ?? 0}',
              icon: Icons.shopping_cart,
              color: const Color(0xFF4299E1),
            ),
            _buildStatCard(
              title: 'Menunggu',
              value: '${_stats?['pending'] ?? 0}',
              icon: Icons.hourglass_empty,
              color: const Color(0xFFECC94B),
            ),
            _buildStatCard(
              title: 'Diproses',
              value: '${_stats?['processing'] ?? 0}',
              icon: Icons.local_shipping,
              color: const Color(0xFFED8936),
            ),
            _buildStatCard(
              title: 'Selesai',
              value: '${_stats?['completed'] ?? 0}',
              icon: Icons.check_circle,
              color: const Color(0xFF48BB78),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildActionButton(
              icon: Icons.add_box,
              label: 'Tambah Produk',
              onTap: () => Navigator.pushNamed(context, '/admin/products'),
            ),
            _buildActionButton(
              icon: Icons.image,
              label: 'Kelola Banner',
              onTap: () => Navigator.pushNamed(context, '/admin/banners'),
            ),
            _buildActionButton(
              icon: Icons.receipt_long,
              label: 'Lihat Pesanan',
              onTap: () => Navigator.pushNamed(context, '/admin/orders'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFD84A7E)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // WIDGET PRODUK TERBARU
  // ============================================
  Widget _buildRecentProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Produk Terbaru',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/admin/products'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                'Lihat Semua',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ProductModel>>(
          stream: _productRepo.getAllProductsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorCard('Error: ${snapshot.error}');
            }

            final products = snapshot.data ?? [];

            if (products.isEmpty) {
              return _buildEmptyCard(
                icon: Icons.inventory_2_outlined,
                title: 'Belum Ada Produk',
                subtitle: 'Tambahkan produk pertama Anda',
                buttonLabel: 'Tambah Produk',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/admin/products'),
              );
            }

            // Tampilkan 5 produk terbaru
            final recentProducts = products.take(5).toList();

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('Gambar',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('Nama Produk',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Kategori',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Harga',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('Status',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Product rows
                  ...recentProducts
                      .map((product) => _buildProductRow(product)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductRow(ProductModel product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Image
          SizedBox(
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            flex: 4,
            child: Text(
              product.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: const Color(0xFF2D3748),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Category
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD84A7E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.category,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFFD84A7E),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Price
          Expanded(
            flex: 2,
            child: Text(
              'Rp ${_formatPrice(product.price)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
          // Status
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: product.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                product.isActive ? 'Aktif' : 'Nonaktif',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: product.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 40,
      height: 40,
      color: Colors.grey[100],
      child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 20),
    );
  }

  // ============================================
  // WIDGET BANNER TERBARU
  // ============================================
  Widget _buildRecentBannersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Banner Aktif',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/admin/banners'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                'Lihat Semua',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<BannerModel>>(
          stream: _bannerRepo.getAllBannersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorCard('Error: ${snapshot.error}');
            }

            final banners = snapshot.data ?? [];

            if (banners.isEmpty) {
              return _buildEmptyCard(
                icon: Icons.photo_library_outlined,
                title: 'Belum Ada Banner',
                subtitle: 'Tambahkan banner promosi Anda',
                buttonLabel: 'Tambah Banner',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/admin/banners'),
              );
            }

            return SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: banners.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return _buildBannerCard(banner);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBannerCard(BannerModel banner) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                banner.imageUrl.isNotEmpty
                    ? Image.network(
                        banner.imageUrl,
                        width: 320,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 320,
                          height: 140,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image,
                              color: Colors.grey, size: 40),
                        ),
                      )
                    : Container(
                        width: 320,
                        height: 140,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image,
                            color: Colors.grey, size: 40),
                      ),
                // Status badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: banner.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      banner.isActive ? 'Aktif' : 'Nonaktif',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Banner Info
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Urutan: ${banner.order}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // HELPER WIDGETS
  // ============================================
  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add),
            label: Text(buttonLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD84A7E),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
