import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/product_model.dart';
import '../data/repositories/favorite_repository.dart';
import '../data/repositories/product_repository.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final _favRepo = FavoriteRepository();
  final _prodRepo = ProductRepository();
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view favorites")),
      );
    }

    final body = StreamBuilder<List<String>>(
      stream: _favRepo.getFavoriteIdsStream(_user!.uid),
      builder: (context, favSnapshot) {
        if (favSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final favIds = favSnapshot.data ?? [];

        if (favIds.isEmpty) {
          return _buildEmptyState();
        }

        return StreamBuilder<List<ProductModel>>(
          stream: _prodRepo.getAllProductsStream(), // Fetch all to filter locally
          builder: (context, prodSnapshot) {
             if (prodSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allProducts = prodSnapshot.data ?? [];
            final favProducts = allProducts.where((p) => favIds.contains(p.id)).toList();

            if (favProducts.isEmpty) {
              // IDs exist in favs but products might be deleted/inactive
              // Optionally cleanup favs here, but for now just show empty
              return _buildEmptyState();
            }

            return _buildProductList(favProducts);
          },
        );
      },
    );

    if (widget.embedded) {
      return Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            _buildEmbeddedHeader('My Favorites'),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Favorites',
          style: GoogleFonts.lobster(
            color: const Color(0xFF1E3A5F),
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E3A5F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: body,
    );
  }

  Widget _buildEmbeddedHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.lobster(
            color: const Color(0xFF1E3A5F),
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No favorites yet",
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Gambar Produk
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                        )
                      : Container(color: Colors.grey[200]),
                ),
              ),
              const SizedBox(width: 16),
              // Info Produk
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${product.price}', // Format rupiah better if reused helper
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE67E22),
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol Hapus / Love
              IconButton(
                onPressed: () {
                   if (_user != null) {
                    _favRepo.removeFavorite(_user!.uid, product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} removed from favorites'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                   }
                },
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
