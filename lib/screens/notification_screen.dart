import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy notifikasi
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Pembayaran Telah Diterima',
        'message': 'Pembayaran untuk pesanan #ORD-2023 telah diterima. Penjual sedang menyiapkan pesananmu.',
        'time': 'Baru saja',
        'type': 'success',
        'isRead': false,
      },
      {
        'title': 'Pesanan Dibatalkan',
        'message': 'Pesanan #ORD-2021 telah dibatalkan. Silakan hubungi customer service untuk info lebih lanjut.',
        'time': '2 jam yang lalu',
        'type': 'alert',
        'isRead': true,
      },
      {
        'title': 'Pembayaran Dibatalkan',
        'message': 'Pembayaran untuk pesanan #ORD-2020 dibatalkan karena batas waktu pembayaran habis.',
        'time': '1 hari yang lalu',
        'type': 'alert',
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: GoogleFonts.lobster(
            color: const Color(0xFF1E3A5F),
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E3A5F)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Mark all read",
              style: GoogleFonts.poppins(
                color: const Color(0xFFE67E22),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return _buildNotificationCard(item);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    // Tentukan warna dan icon berdasarkan tipe notifikasi
    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    switch (item['type']) {
      case 'success':
        iconBgColor = Colors.green.withOpacity(0.1);
        iconColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case 'alert':
        iconBgColor = Colors.red.withOpacity(0.1);
        iconColor = Colors.red;
        iconData = Icons.cancel;
        break;
      case 'promo':
        iconBgColor = Colors.orange.withOpacity(0.1);
        iconColor = Colors.orange;
        iconData = Icons.local_offer;
        break;
      default: // info
        iconBgColor = Colors.blue.withOpacity(0.1);
        iconColor = Colors.blue;
        iconData = Icons.local_shipping;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item['isRead'] ? Colors.white : const Color(0xFFF0F7FF), // Biru muda jika belum dibaca
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: item['isRead'] 
            ? Border.all(color: Colors.transparent)
            : Border.all(color: const Color(0xFF1E3A5F).withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ),
                    Text(
                      item['time'],
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['message'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}