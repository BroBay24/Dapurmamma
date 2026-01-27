import 'package:cloud_functions/cloud_functions.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  MidtransSDK? _midtrans;

  // Inisialisasi SDK (Hanya di Mobile)
  Future<void> initSDK() async {
    if (kIsWeb) return;

    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: 'YOUR_MIDTRANS_CLIENT_KEY', // PLACEHOLDER
        merchantBaseUrl: '', // Kosongkan karena kita pakai Cloud Functions untuk token
        colorTheme: ColorTheme(
          colorPrimary: 0xFFFF9800, // Warna orange Dapur Mamma
          colorPrimaryDark: 0xFFF57C00,
          colorSecondary: 0xFFFF9800,
        ),
      ),
    );

    _midtrans?.setTransactionFinishedCallback((result) {
      if (kDebugMode) {
        print('Transaction Finished: ${result.status}');
      }
      // KRITIS: Jangan anggap result.status == 'success' sebagai bukti bayar.
      // Status asli harus dicek dari backend.
    });
  }

  /// Memulai proses pembayaran
  /// [orderIdDoc] adalah Document ID Firestore
  Future<void> startPayment(String orderIdDoc) async {
    try {
      // 1. Panggil Backend untuk buat transaksi dan dapatkan Snap Token
      final result = await _functions
          .httpsCallable('createMidtransTransaction')
          .call({'orderId': orderIdDoc});

      final String snapToken = result.data['token'];

      // 2. Tampilkan UI Snap
      if (kIsWeb) {
        // Untuk Web, buka redirect_url di tab baru atau iframe
        final String redirectUrl = result.data['redirect_url'];
        // logic to open URL (e.g. url_launcher)
      } else {
        // Untuk Mobile, gunakan native SDK
        if (_midtrans == null) await initSDK();
        _midtrans?.startPaymentUi(token: snapToken);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Payment Error: $e');
      }
      rethrow;
    }
  }
}
