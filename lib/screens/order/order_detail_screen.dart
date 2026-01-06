import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  int _qty = 1;
  String _payment = 'Qris';

  @override
  Widget build(BuildContext context) {
    // Dummy data (nanti bisa dari ProductDetail / backend)
    const String productName = 'Bolu Coklat Vanila';
    const int unitPrice = 50000;

    final int subtotal = unitPrice * _qty;
    final int total = subtotal;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E3A5F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Detail',
          style: GoogleFonts.lobster(
            fontSize: 24,
            color: const Color(0xFFE95E2E),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 900;
            final double maxWidth = isWide ? 1100 : constraints.maxWidth;
            final double horizontalPadding = isWide ? 26 : 20;

            final Widget orderCard = _card(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/icons/bolukacang.jpg',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E3A5F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatRupiah(unitPrice),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE67E22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _qtyControl(),
                ],
              ),
            );

            final Widget paymentCard = _card(
              child: Column(
                children: [
                  _paymentTile('Qris', Icons.qr_code_2),
                  const SizedBox(height: 8),
                  _paymentTile('Gopay', Icons.account_balance_wallet_outlined),
                ],
              ),
            );

            final Widget summaryCard = _card(
              child: Column(
                children: [
                  _summaryRow('Subtotal', _formatRupiah(subtotal)),
                  const SizedBox(height: 14),
                  Divider(height: 1, color: Colors.grey[200]),
                  const SizedBox(height: 14),
                  _summaryRow(
                    'Total Bayar',
                    _formatRupiah(total),
                    isTotal: true,
                  ),
                ],
              ),
            );

            final Widget content = isWide
                ? Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 520,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Pesanan'),
                            const SizedBox(height: 10),
                            orderCard,
                            const SizedBox(height: 16),
                            _sectionTitle('Metode Pembayaran'),
                            const SizedBox(height: 10),
                            paymentCard,
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 420,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Ringkasan Pembayaran'),
                            const SizedBox(height: 10),
                            summaryCard,
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Pesanan'),
                      const SizedBox(height: 10),
                      orderCard,
                      const SizedBox(height: 16),
                      _sectionTitle('Metode Pembayaran'),
                      const SizedBox(height: 10),
                      paymentCard,
                      const SizedBox(height: 16),
                      _sectionTitle('Ringkasan Pembayaran'),
                      const SizedBox(height: 10),
                      summaryCard,
                    ],
                  );

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: content,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red, width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                'Batalkan Pesanan',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/success');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF111111),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Bayar Sekarang',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _qtyControl() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE67E22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _qtyButton(
            icon: Icons.remove,
            onTap: () {
              if (_qty > 1) {
                setState(() => _qty--);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$_qty',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          _qtyButton(
            icon: Icons.add,
            onTap: () => setState(() => _qty++),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _paymentTile(String label, IconData icon) {
    final bool selected = _payment == label;
    return InkWell(
      onTap: () => setState(() => _payment = label),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFE67E22) : Colors.grey.shade300,
            width: selected ? 1.6 : 1,
          ),
          color: selected ? const Color(0xFFE67E22).withOpacity(0.08) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1E3A5F)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A5F),
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? const Color(0xFFE67E22) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE67E22),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 13.5 : 12.5,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 14.5 : 12.5,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: isTotal ? const Color(0xFF111111) : const Color(0xFF1E3A5F),
          ),
        ),
      ],
    );
  }
}

String _formatRupiah(int value) {
  final formatted = value
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return 'Rp $formatted';
}
