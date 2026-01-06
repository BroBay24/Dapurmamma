import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data (silakan sambungkan ke backend)
    final List<Map<String, dynamic>> orders = [
      {
        'id': 'ID-01',
        'dateTime': '10 Des 2025, 18:45',
        'items': 'Bolu Coklat Kacang',
        'total': '20.000',
        'status': 'Diproses',
        'payment': 'Qris',
      },
      {
        'id': 'ID-02',
        'dateTime': '10 Des 2025, 18:45',
        'items': 'Bolu Coklat Durian',
        'total': '20.000',
        'status': 'Dibatalkan',
        'payment': 'Qris',
      },
      {
        'id': 'ID-03',
        'dateTime': '10 Des 2025, 18:45',
        'items': 'Bolu Coklat Strawberry',
        'total': '20.000',
        'status': 'Selesai',
        'payment': 'Gopay',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Order History',
          style: GoogleFonts.lobster(
            color: const Color(0xFFE95E2E),
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E3A5F)),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
              return;
            }

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 900;
          final double maxWidth = isWide ? 1100 : constraints.maxWidth;
          final double horizontalPadding = isWide ? 24 : 20;
          final double cardWidth = isWide ? (maxWidth - 16) / 2 : maxWidth;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: orders.map((order) {
                    return SizedBox(
                      width: cardWidth,
                      child: _buildOrderCard(context, order),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    Color statusColor;
    Color statusBgColor;

    const dividerColor = Color(0xFFB8A9A0);
    const textMuted = Color(0xFFE6DBD5);

    switch (order['status']) {
      case 'Diproses':
        statusColor = const Color(0xFFE67E22);
        statusBgColor = const Color(0xFFE67E22).withOpacity(0.15);
        break;
      case 'Selesai':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.15);
        break;
      case 'Dibatalkan':
        statusColor = Colors.red;
        statusBgColor = Colors.red.withOpacity(0.15);
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withOpacity(0.15);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5045), Color(0xFF594037)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Header: ID & Date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/icons/archiveicon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['items'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order['id'],
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        order['dateTime'],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Container(height: 1, color: dividerColor),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metode Pembayaran',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order['payment'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Pesanan',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              order['status'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Container(height: 1, color: dividerColor),
                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Harga',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${order['total']}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal dan Waktu',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order['dateTime'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}