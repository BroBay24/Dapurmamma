import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dapurmamma/auth_gate.dart';
import 'package:dapurmamma/firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/home/product_detail_screen.dart';
import 'screens/order/order_detail_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/order_history_screen.dart';
import 'screens/success_screen.dart';
// Admin Panel imports
import 'admin/screens/admin_dashboard_screen.dart';
import 'admin/screens/admin_products_screen.dart';
import 'admin/screens/admin_banners_screen.dart';
import 'admin/screens/admin_orders_screen.dart';
import 'admin/screens/admin_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dapur Mamma',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const _AppBootstrap(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/favorite': (context) => const FavoriteScreen(),
        '/product_detail': (context) => const ProductDetailScreen(),
        '/order_detail': (context) => const OrderDetailScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/order_history': (context) => const OrderHistoryScreen(),
        '/success': (context) => const SuccessScreen(),
        '/auth_gate':(context) => const AuthGate(),
        // Admin Panel routes
        '/admin/login': (context) => const AdminLoginScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/admin/products': (context) => const AdminProductsScreen(),
        '/admin/banners': (context) => const AdminBannersScreen(),
        '/admin/orders': (context) => const AdminOrdersScreen(),
      },
    );
  }
}

class _AppBootstrap extends StatelessWidget {
  const _AppBootstrap();

  Future<void> _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _BootstrapLoading();
        }

        if (snapshot.hasError) {
          return _FirebaseInitErrorScreen(error: snapshot.error);
        }

        // Firebase ready; proceed to your existing flow.
        return const SplashScreen();
      },
    );
  }
}

class _BootstrapLoading extends StatelessWidget {
  const _BootstrapLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFB71C1C),
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Image(
            image: AssetImage('assets/icons/DapurMamma.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _FirebaseInitErrorScreen extends StatelessWidget {
  const _FirebaseInitErrorScreen({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Firebase belum dikonfigurasi untuk Windows',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  'Aplikasi tidak bisa lanjut karena inisialisasi Firebase gagal. '
                  'Ini sering terjadi jika file firebase_options.dart belum memiliki konfigurasi Windows.',
                  style: TextStyle(color: Colors.grey.shade800, height: 1.35),
                ),
                const SizedBox(height: 10),
                Text(
                  'Detail: ${error ?? '-'}',
                  style: TextStyle(color: Colors.grey.shade700, height: 1.35),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Perbaikan:',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  '1) Jalankan: flutterfire configure\n'
                  '2) Pastikan memilih platform Windows\n'
                  '3) Build ulang: flutter build windows',
                  style: TextStyle(color: Colors.grey.shade800, height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
