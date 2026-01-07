import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      appBar: AppBar(
        title: Text(
          'Detail Pesanan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
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
            final contentMaxWidth = width >= 900 ? 760.0 : double.infinity;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Pesanan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E3A5F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        title: 'Order 1',
                        amount: 'Rp 35.000',
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        title: 'Total Bayar',
                        amount: 'Rp 35.000',
                        isTotal: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/success');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111111),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Bayar Sekarang',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? const Color(0xFFE67E22) : const Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }
}
