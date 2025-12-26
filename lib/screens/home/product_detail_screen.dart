import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;

  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String name = (args?['name'] ?? 'Bolu Coklat Vanila') as String;
    final String id = (args?['id'] ?? 'ID-01') as String;
    final String image = (args?['image'] ?? 'assets/icons/bolukacang.jpg') as String;
    final int price = (args?['price'] ?? 50000) as int;
    final int stock = (args?['stock'] ?? 10) as int;
    final String description = (args?['description'] ??
            'Our Strawberry Birthday Cake is made with soft vanilla sponge layers and a light whipped cream frosting. '
                'Each layer includes a simple, fresh strawberry filling—made from real strawberries—nothing artificial—so the flavor stays naturally sweet and slightly tangy.')
        as String;

    final bool shouldShowMore = description.trim().length > 170;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                child: Column(
                  children: [
                    // Header (gradient + image)
                    Container(
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
                                onTap: () => setState(() => _isFavorite = !_isFavorite),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: AspectRatio(
                              aspectRatio: 16 / 10,
                              child: Image.asset(
                                image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Content Card
                    Container(
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
                                  overflow:
                                      _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
                                      _isDescriptionExpanded
                                          ? 'Tutup'
                                          : 'Lihat selengkapnya',
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
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
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
                          Navigator.pushNamed(context, '/order_detail');
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
            ),
          ],
        ),
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
