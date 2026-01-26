import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;

  const AdminSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFFD84A7E),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/icons/DapurMamma.png',
              height: 110,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cake, color: Colors.white, size: 40),
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          // Admin label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white.withOpacity(0.1),
            child: Text(
              'PANEL ADMIN',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
          ),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/admin',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.inventory_2,
                  label: 'Produk',
                  route: '/admin/products',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.photo_library,
                  label: 'Banner',
                  route: '/admin/banners',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.shopping_bag,
                  label: 'Pesanan',
                  route: '/admin/orders',
                ),
              ],
            ),
          ),
          // Divider
          const Divider(color: Colors.white24, height: 1),
          // Footer actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.home,
                  label: 'Lihat Aplikasi',
                  route: '/home',
                  isExternal: true,
                ),
                _buildLogoutItem(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/admin/login',
                (route) => false,
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.logout, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Keluar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    bool isExternal = false,
  }) {
    final isSelected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            if (isExternal) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                route,
                (route) => false,
              );
            } else if (currentRoute != route) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
