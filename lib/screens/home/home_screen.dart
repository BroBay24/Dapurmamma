import 'dart:async';
 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/favorite_screen.dart';
import 'package:myapp/screens/notification_screen.dart';
import 'package:myapp/screens/profile/profile_screen.dart';
 
class _Product {
  const _Product({
    required this.name,
    required this.store,
    required this.price,
    required this.fallbackAssetPath,
    required this.isFavorite,
    this.imageUrl,
  });
 
  final String name;
  final String store;
  final int price;
 
  // Untuk sekarang pakai asset statis; nanti bisa diganti URL dari panel admin.
  final String fallbackAssetPath;
  final String? imageUrl;
  final bool isFavorite;
 
  _Product copyWith({
    String? name,
    String? store,
    int? price,
    String? fallbackAssetPath,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return _Product(
      name: name ?? this.name,
      store: store ?? this.store,
      price: price ?? this.price,
      fallbackAssetPath: fallbackAssetPath ?? this.fallbackAssetPath,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
 
class _HomeBanner {
  const _HomeBanner({this.imageUrl, required this.fallbackAssetPath});
 
  // Untuk admin panel: nanti gunakan URL hasil upload.
  final String? imageUrl;
 
  // Fallback supaya tetap ada gambar walau URL belum tersedia.
  final String fallbackAssetPath;
}
 
class _BannerImage extends StatelessWidget {
  const _BannerImage({required this.imageUrl, required this.fallbackAssetPath});
 
  final String? imageUrl;
  final String fallbackAssetPath;
 
  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.trim().isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(fallbackAssetPath, fit: BoxFit.cover);
        },
      );
    }
    return Image.asset(fallbackAssetPath, fit: BoxFit.cover);
  }
}
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
 
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = const [
    'All',
    'Cake',
    'Cookies',
    'Dessert',
    'Bread',
  ];
  int _selectedCategoryIndex = 0;
  int _selectedNavIndex = 0;
 
  final PageController _bannerController = PageController(
    viewportFraction: 0.92,
  );
  int _bannerIndex = 0;
  Timer? _bannerTimer;
 
  late List<_Product> _products;
  late final List<_HomeBanner> _banners;
 
  @override
  void initState() {
    super.initState();
    _banners = <_HomeBanner>[
      const _HomeBanner(
        imageUrl: null,
        fallbackAssetPath: 'assets/icons/bolukacang.jpg',
      ),
      const _HomeBanner(
        imageUrl: null,
        fallbackAssetPath: 'assets/icons/bolukacang.jpg',
      ),
      const _HomeBanner(
        imageUrl: null,
        fallbackAssetPath: 'assets/icons/bolukacang.jpg',
      ),
    ];
 
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (!_bannerController.hasClients) return;
      final next = (_bannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
    _products = <_Product>[
      const _Product(
        name: 'Choco Lava',
        store: 'SWEET TOOTH',
        price: 35000,
        fallbackAssetPath: 'assets/icons/bolukacang.jpg',
        isFavorite: false,
      ),
      const _Product(
        name: 'Cheese Cake',
        store: 'CAKEMAMMA HQ',
        price: 40000,
        fallbackAssetPath: 'assets/icons/bolukacang.jpg',
        isFavorite: false,
      ),
      const _Product(
        name: 'Red Velvet',
        store: 'CAKEMAMMA HQ',
        price: 38000,
        fallbackAssetPath: 'assets/icons/bolukacang.jpg',
        isFavorite: true,
      ),
      const _Product(
        name: 'Banana Bread',
        store: 'OVEN HOUSE',
        price: 30000,
        fallbackAssetPath: 'assets/icons/bolukacang.jpg',
        isFavorite: false,
      ),
      const _Product(
        name: 'Brownies',
        store: 'SWEET TOOTH',
        price: 32000,
        fallbackAssetPath: 'assets/icons/bolukacang.jpg',
        isFavorite: false,
      ),
      const _Product(
        name: 'Cookies Jar',
        store: 'CAKEMAMMA HQ',
        price: 28000,
        fallbackAssetPath: 'assets/icons/bolukacang.jpg',
        isFavorite: false,
      ),
    ];
  }
 
  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedNavIndex,
          children: [
            _buildHomeContent(context),
            const FavoriteScreen(embedded: true),
            const NotificationScreen(embedded: true),
            const ProfileScreen(embedded: true),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
 
  Widget _buildHomeContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width >= 1200
            ? 48.0
            : width >= 900
            ? 36.0
            : width >= 650
            ? 24.0
            : 16.0;
        final bannerHeight = width >= 1200
            ? 260.0
            : width >= 900
            ? 230.0
            : width >= 650
            ? 190.0
            : 160.0;
        final gridColumns = width >= 1400
            ? 5
            : width >= 1200
            ? 4
            : width >= 900
            ? 3
            : width >= 650
            ? 2
            : 1;
        final gridAspectRatio = width >= 1400
            ? 1.42
            : width >= 1200
            ? 1.32
            : width >= 900
            ? 1.24
            : width >= 650
            ? 1.14
            : 1.5;
        final imageHeight = width >= 1200
            ? 120.0
            : width >= 900
            ? 110.0
            : width >= 650
            ? 90.0
            : 130.0;
 
        final gridTileWidth =
            (width - (horizontalPadding * 2) - (16 * (gridColumns - 1))) /
            gridColumns;
        final gridTileHeight = (gridTileWidth / gridAspectRatio) + 30;
 
        return Column(
          children: [
            _buildHeader(horizontalPadding: horizontalPadding),
            _buildBannerCarousel(
              horizontalPadding: horizontalPadding,
              bannerHeight: bannerHeight,
            ),
            _buildSearchBar(horizontalPadding: horizontalPadding),
            _buildCategories(horizontalPadding: horizontalPadding),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Now',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth >= 900 ? 20 : 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildProductGrid(
                horizontalPadding: horizontalPadding,
                crossAxisCount: gridColumns,
                childAspectRatio: gridAspectRatio,
                itemHeight: gridTileHeight,
                imageHeight: imageHeight,
              ),
            ),
          ],
        );
      },
    );
  }
 
  Widget _buildHeader({required double horizontalPadding}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Original buatan mama, Order Sekarang!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Cake',
                      style: GoogleFonts.lobster(
                        fontSize: 30,
                        color: const Color(0xFFE67E22),
                      ),
                    ),
                    TextSpan(
                      text: 'Mamma',
                      style: GoogleFonts.lobster(
                        fontSize: 30,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
                image: const DecorationImage(
                  image: AssetImage('assets/icons/bolukacang.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildBannerCarousel({
    required double horizontalPadding,
    required double bannerHeight,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 6),
      child: Column(
        children: [
          SizedBox(
            height: bannerHeight,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _banners.length,
              onPageChanged: (index) {
                setState(() {
                  _bannerIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _BannerImage(
                          imageUrl: banner.imageUrl,
                          fallbackAssetPath: banner.fallbackAssetPath,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.35),
                                Colors.black.withOpacity(0.10),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 14,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: InkWell(
                              onTap: () {
                                final next =
                                    (_bannerIndex + 1) % _banners.length;
                                _bannerController.animateToPage(
                                  next,
                                  duration: const Duration(milliseconds: 320),
                                  curve: Curves.easeOut,
                                );
                              },
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF1E3A5F),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(_banners.length, (i) {
              final isActive = i == _bannerIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(left: 6),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE67E22)
                      : Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
 
  Widget _buildSearchBar({required double horizontalPadding}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search for snacks...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _buildCategories({required double horizontalPadding}) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding - 4),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1E3A5F)
                      : Colors.grey[300]!,
                ),
              ),
              child: Text(
                _categories[index],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
 
  Widget _buildProductGrid({
    required double horizontalPadding,
    required int crossAxisCount,
    required double childAspectRatio,
    required double itemHeight,
    required double imageHeight,
  }) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
        mainAxisExtent: itemHeight,
      ),
      cacheExtent: 800,
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index], index, imageHeight);
      },
    );
  }
 
  Widget _buildProductCard(_Product product, int index, double imageHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product_detail');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(26),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _buildProductImage(product, imageHeight),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.store,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Rp${_formatPrice(product.price)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE67E22),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _products[index] = _products[index].copyWith(
                                isFavorite: !product.isFavorite,
                              );
                            });
                          },
                          child: Icon(
                            product.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 22,
                            color: product.isFavorite
                                ? Colors.red
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _buildProductImage(_Product product, double height) {
    if (product.imageUrl != null && product.imageUrl!.trim().isNotEmpty) {
      return Image.network(
        product.imageUrl!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            product.fallbackAssetPath,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          );
        },
      );
    }
 
    return Image.asset(
      product.fallbackAssetPath,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
    );
  }
 
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
 
  Widget _buildBottomNavBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE67E22), Color(0xFFF39C12)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE67E22).withAlpha(90),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.favorite_border_rounded, 'Favorit'),
              _buildNavItem(2, Icons.notifications_none_rounded, 'Info'),
              _buildNavItem(3, Icons.person_outline_rounded, 'Akun'),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? const Color(0xFFE67E22) : Colors.white,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: SizedBox(width: isSelected ? 6 : 0),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isSelected ? 1 : 0,
              child: isSelected
                  ? Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE67E22),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}