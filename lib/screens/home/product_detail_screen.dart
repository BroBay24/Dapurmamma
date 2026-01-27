import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/favorite_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import '../../data/models/order_model.dart';
import 'dart:async';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductRepository _productRepo = ProductRepository();
  final FavoriteRepository _favRepo = FavoriteRepository();
  final User? _user = FirebaseAuth.instance.currentUser;
  StreamSubscription? _favSubscription;
  
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // We'll initialize the favorite listener in didChangeDependencies since we need argId
  }

  bool _isInit = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit && _user != null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String argId = (args?['id'] ?? '') as String;
      
      _favSubscription = _favRepo.getFavoriteIdsStream(_user!.uid).listen((ids) {
        if (mounted) {
          setState(() {
            _isFavorite = ids.contains(argId);
          });
        }
      });
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _favSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String argId = (args?['id'] ?? '') as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      body: StreamBuilder<ProductModel?>(
        stream: _productRepo.getProductStream(argId),
        builder: (context, snapshot) {
          // Use stream data if available, otherwise fallback to args
          final product = snapshot.data;

          final String name = product?.name ?? (args?['name'] ?? 'Loading...') as String;
          // Use readable productId for display if available
          final String displayId = product?.productId ?? (args?['productId'] ?? (args?['id'] ?? '')) as String;
          final String image = product?.imageUrl ?? (args?['image'] ?? 'assets/icons/bolukacang.jpg') as String;
          
          final int basePrice = product?.price ?? (args?['price'] ?? 0) as int;
          final int stock = product?.stock ?? (args?['stock'] ?? 0) as int;
          
          final String description = product?.description ?? (args?['description'] ?? '') as String;
          final bool shouldShowMore = description.trim().length > 170;

          // Calculate total price based on quantity
          final int totalPrice = basePrice * _quantity;

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final horizontalPadding = width >= 1200
                    ? 48.0
                    : width >= 900
                        ? 36.0
                        : width >= 650
                            ? 24.0
                            : 16.0;
                final isWide = width >= 900;
                final imageAspectRatio = isWide ? 16 / 9 : 16 / 10;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 14),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: _buildHeaderCard(
                                      image: image,
                                      imageAspectRatio: imageAspectRatio,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 5,
                                    child: _buildContentCard(
                                      name: name,
                                      id: displayId,
                                      description: description,
                                      shouldShowMore: shouldShowMore,
                                      stock: stock,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildHeaderCard(
                                    image: image,
                                    imageAspectRatio: imageAspectRatio,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildContentCard(
                                    name: name,
                                    id: displayId,
                                    description: description,
                                    shouldShowMore: shouldShowMore,
                                    stock: stock,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    _buildBottomBar(horizontalPadding, totalPrice),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard({
    required String image,
    required double imageAspectRatio,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE67E22).withOpacity(0.40),
            const Color(0xFFE67E22).withOpacity(0.15),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
              _CircleIconButton(
                icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                iconColor: _isFavorite ? Colors.red : const Color(0xFF1E3A5F),
                onTap: () {
                  if (_user != null) {
                    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                    final String argId = (args?['id'] ?? '') as String;
                    
                    if (_isFavorite) {
                      _favRepo.removeFavorite(_user!.uid, argId);
                    } else {
                      _favRepo.addFavorite(_user!.uid, argId);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please login to save favorites')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: imageAspectRatio,
              child: image.startsWith('http')
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/icons/bolukacang.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[300]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard({
    required String name,
    required String id,
    required String description,
    required bool shouldShowMore,
    required int stock,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE67E22),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  id,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  maxLines: _isDescriptionExpanded ? null : 4,
                  overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    height: 1.55,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (shouldShowMore) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(
                      () => _isDescriptionExpanded = !_isDescriptionExpanded,
                    ),
                    child: Text(
                      _isDescriptionExpanded ? 'Tutup' : 'Lihat selengkapnya',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE67E22),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Keterangan',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'Tambahkan Keterangan...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE67E22),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Stok $stock',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Porsi',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _SquareCounterButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$_quantity',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _SquareCounterButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double horizontalPadding, int price) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE67E22).withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              _formatRupiah(price),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final item = OrderItemModel(
                    productId: argId,
                    productName: name,
                    quantity: _quantity,
                    price: basePrice,
                  );

                  Navigator.pushNamed(
                    context,
                    '/order_detail',
                    arguments: {
                      'checkoutData': {
                        'items': [item],
                        'total': price, // Ini adalah totalPrice (basePrice * quantity)
                      }
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'CheckOut',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = const Color(0xFF1E3A5F),
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}

class _SquareCounterButton extends StatelessWidget {
  const _SquareCounterButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFE67E22),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

String _formatRupiah(int value) {
  final formatted = value
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return 'Rp$formatted';
}
