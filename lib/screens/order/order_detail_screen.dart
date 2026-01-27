import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/services/payment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderRepository _orderRepo = OrderRepository();
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // Check if we are showing an existing order or creating a new one (checkout)
    final OrderModel? existingOrder = args?['order'] as OrderModel?;
    final Map<String, dynamic>? checkoutData = args?['checkoutData'] as Map<String, dynamic>?;

    final String title = existingOrder != null ? 'Detail Pesanan' : 'Konfirmasi Pesanan';
    final String orderId = existingOrder?.orderId ?? 'Baru';
    final int total = existingOrder?.total ?? (checkoutData?['total'] ?? 0) as int;
    final List<OrderItemModel> items = existingOrder?.items ?? (checkoutData?['items'] as List<OrderItemModel>? ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = width >= 1200 ? 48.0 : width >= 900 ? 36.0 : width >= 650 ? 24.0 : 16.0;
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
                      if (existingOrder != null) ...[
                         _buildInfoRow('ID Pesanan', orderId),
                         _buildInfoRow('Status', OrderModel.statusToLabel(existingOrder.status)),
                         const SizedBox(height: 20),
                      ],
                      Text(
                        'Ringkasan Pesanan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E3A5F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildSummaryCard(
                          title: '${item.productName} x${item.quantity}',
                          amount: _formatRupiah(item.price * item.quantity),
                        ),
                      )).toList(),
                      const Divider(height: 32),
                      _buildSummaryCard(
                        title: 'Total Bayar',
                        amount: _formatRupiah(total),
                        isTotal: true,
                      ),
                      const SizedBox(height: 32),
                      if (existingOrder == null || existingOrder.status == OrderStatus.pending)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _handlePayment(existingOrder, checkoutData),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE67E22),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              existingOrder == null ? 'Buat Pesanan & Bayar' : 'Bayar Sekarang',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
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

  Future<void> _handlePayment(OrderModel? existingOrder, Map<String, dynamic>? checkoutData) async {
    setState(() => _isLoading = true);
    try {
      String docId = '';
      
      if (existingOrder == null && checkoutData != null) {
        // Create new order first
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw 'User not logged in';

        final newOrder = OrderModel(
          id: '', // Will be generated by Firestore
          orderId: '', // Will be generated by Repo
          userId: user.uid,
          customerName: user.displayName ?? 'Customer',
          items: checkoutData['items'],
          total: checkoutData['total'],
          paymentMethod: 'Midtrans Snap',
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        docId = await _orderRepo.createOrder(newOrder);
      } else if (existingOrder != null) {
        docId = existingOrder.id;
      }

      if (docId.isNotEmpty) {
        await _paymentService.startPayment(docId);
        // SDK akan handle UI. Setelah selesai, status akan update via Webhook.
        // Kita bisa arahkan user ke halaman sukses atau list order.
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Menunggu pembayaran...')),
           );
           Navigator.pushReplacementNamed(context, '/success');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai pembayaran: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  String _formatRupiah(int value) {
    final formatted = value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp$formatted';
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
