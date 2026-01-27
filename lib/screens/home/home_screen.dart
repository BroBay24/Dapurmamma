import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/favorite_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/banner_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/product_model.dart';
import '../../data/models/banner_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = const [
    'All',
    'Dessert Cakes & Tarts',
    'Cookies & Shortbread',
    'Sponge & Butter Cakes',
    'Sponge Cake',
    'Pastry',
  ];
  int _selectedCategoryIndex = 0;
  int _selectedNavIndex = 0;

  final PageController _bannerController = PageController(viewportFraction: 0.92);
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  // Repositories
  late final ProductRepository _productRepo;
  late final BannerRepository _bannerRepo;
  late final FavoriteRepository _favRepo;
  final User? _user = FirebaseAuth.instance.currentUser;
  StreamSubscription? _favSubscription;
  
  // Data dari Firestore
  List<ProductModel> _products = [];
  List<BannerModel> _banners = [];
  Set<String> _favoriteIds = {};
  bool _isLoadingProducts = true;
  bool _isLoadingBanners = true;

  @override
  void initState() {
    super.initState();
    _productRepo = ProductRepository();
    _bannerRepo = BannerRepository();
    _favRepo = FavoriteRepository();
    
    _startBannerTimer();

    // Listen to favorites
    if (_user != null) {
      _favSubscription = _favRepo.getFavoriteIdsStream(_user!.uid).listen((ids) {
        if (mounted) {
          setState(() {
            _favoriteIds = ids.toSet();
          });
        }
      });
    }
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (!_bannerController.hasClients) return;
      if (_banners.isEmpty) return;
      final next = (_bannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _favSubscription?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 1000;
        final double maxContentWidth = isWide ? 1200 : constraints.maxWidth;
        final double horizontalPadding = isWide ? 28 : 20;
        final int gridCrossAxisCount = constraints.maxWidth >= 1250
            ? 4
            : constraints.maxWidth >= 900
                ? 3
                : 2;
        final double gridAspectRatio = constraints.maxWidth >= 1250
            ? 0.98
            : constraints.maxWidth >= 900
                ? 0.95
                : 0.90;
        final double bannerHeight = isWide ? 200 : 160;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  children: [
                    _buildHeader(horizontalPadding),
                    _buildBannerCarousel(horizontalPadding, bannerHeight),
                    _buildSearchBar(horizontalPadding),
                    _buildCategories(horizontalPadding),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildProductGrid(
                        gridCrossAxisCount,
                        horizontalPadding,
                        gridAspectRatio,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
    );
  }

  Widget _buildHeader(double horizontalPadding) {
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
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: UserRepository().getUserStream(),
            builder: (context, snapshot) {
              String? photoUrl;
              if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                photoUrl = snapshot.data!.data()?['photoUrl'];
              }
              
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    image: DecorationImage(
                      image: photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : const AssetImage('assets/icons/bolukacang.jpg') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel(double horizontalPadding, double bannerHeight) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 6),
      child: Column(
        children: [
          SizedBox(
            height: bannerHeight,
            child: StreamBuilder<List<BannerModel>>(
              stream: _bannerRepo.getActiveBannersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _banners.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final banners = snapshot.data ?? [];
                
                // Update local banners for timer logic (without triggering rebuild loop)
                if (banners.isNotEmpty) {
                  _banners = banners;
                  _isLoadingBanners = false;
                }

                // Jika tidak ada banner, tampilkan placeholder
                if (banners.isEmpty) {
                  return _buildEmptyBannerPlaceholder(bannerHeight);
                }

                return PageView.builder(
                  controller: _bannerController,
                  itemCount: banners.length,
                  onPageChanged: (index) {
                    setState(() {
                      _bannerIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildBannerImage(banner.imageUrl),
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
                            // Banner title overlay
                            Positioned(
                              left: 16,
                              bottom: 16,
                              child: Text(
                                banner.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
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
                                    final next = (_bannerIndex + 1) % banners.length;
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
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<BannerModel>>(
            stream: _bannerRepo.getActiveBannersStream(),
            builder: (context, snapshot) {
              final banners = snapshot.data ?? [];
              if (banners.isEmpty) return const SizedBox.shrink();
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(banners.length, (i) {
                  final isActive = i == _bannerIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 6),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFE67E22) : Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBannerPlaceholder(double height) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE67E22).withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE67E22).withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, 
                size: 40, color: const Color(0xFFE67E22).withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              'Banner akan muncul di sini',
              style: GoogleFonts.poppins(
                color: const Color(0xFFE67E22).withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/icons/bolukacang.jpg', fit: BoxFit.cover);
        },
      );
    }
    return Image.asset('assets/icons/bolukacang.jpg', fit: BoxFit.cover);
  }

  Widget _buildSearchBar(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
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

  Widget _buildCategories(double horizontalPadding) {
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
                  color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
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

  Widget _buildProductGrid(
    int crossAxisCount,
    double horizontalPadding,
    double childAspectRatio,
  ) {
    // Filter kategori
    final selectedCategory = _categories[_selectedCategoryIndex];
    
    return StreamBuilder<List<ProductModel>>(
      stream: selectedCategory == 'All'
          ? _productRepo.getActiveProductsStream()
          : _productRepo.getProductsByCategoryStream(selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat produk',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data ?? [];

        // Jika tidak ada produk
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada produk',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Produk akan muncul di sini',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          cacheExtent: 800,
          itemCount: products.length,
          itemBuilder: (context, index) {
            return _buildProductCard(products[index]);
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final isFavorite = _favoriteIds.contains(product.id);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Convert ProductModel to Map for ProductDetailScreen
          Navigator.pushNamed(context, '/product_detail', arguments: {
            'id': product.id,
            'productId': product.productId,
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'stock': product.stock,
            'category': product.category,
            'image': product.imageUrl,
          });
        },
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
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _buildProductImage(product),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.productId,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Rp${_formatPrice(product.price)}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE67E22),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_user != null) {
                                if (isFavorite) {
                                  _favRepo.removeFavorite(_user!.uid, product.id);
                                } else {
                                  _favRepo.addFavorite(_user!.uid, product.id);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please login to save favorites')),
                                );
                              }
                            },
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: isFavorite ? Colors.red : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductModel product) {
    if (product.imageUrl.isNotEmpty) {
      return Image.network(
        product.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(Icons.image, color: Colors.grey[400], size: 32),
          );
        },
      );
    }

    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.image, color: Colors.grey[400], size: 32),
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
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE67E22),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(31),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Icons.home_rounded),
              _buildNavItem(1, Icons.favorite_border_rounded),
              _buildNavItem(2, Icons.notifications_none_rounded),
              _buildNavItem(3, Icons.person_outline_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.pushNamed(context, '/favorite');
            break;
          case 2:
            Navigator.pushNamed(context, '/notification');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      child: SizedBox(
        width: 42,
        height: 42,
        child: Center(
          child: isSelected
              ? Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 21,
                    color: const Color(0xFFE67E22),
                  ),
                )
              : Icon(
                  icon,
                  size: 21,
                  color: Colors.white.withAlpha(235),
                ),
        ),
      ),
    );
  }
}
