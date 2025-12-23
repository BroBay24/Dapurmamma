import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // Data dummy untuk tampilan
  final List<Map<String, dynamic>> _favorites = [
    {
      'name': 'Choco Lava',
      'store': 'Sweet Tooth',
      'price': 35000,
      'image': 'assets/icons/bolukacang.jpg', // Ganti dengan asset yang ada
    },
    {
      'name': 'Cheese Cake',
      'store': 'Cakemamma HQ',
      'price': 45000,
      'image': 'assets/icons/bolukacang.jpg',
    },
    {
      'name': 'Red Velvet',
      'store': 'Cakemamma HQ',
      'price': 50000,
      'image': 'assets/icons/bolukacang.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background agak abu terang biar card pop-up
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
      body: _favorites.isEmpty
          ? Center(
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
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = _favorites[index];
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
                          image: DecorationImage(
                            image: AssetImage(item['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info Produk
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E3A5F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['store'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${item['price']}',
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
                          // Logika hapus nanti disini
                          setState(() {
                            _favorites.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item['name']} removed from favorites'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red, // Merah tanda item ini disukai
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}