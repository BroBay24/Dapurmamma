import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Model untuk notifikasi
/// Digunakan untuk menampilkan notifikasi dari FCM atau lokal
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type; // success, alert, promo, info
  final bool isRead;
  final DateTime? createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
    this.createdAt,
  });

  /// Konversi dari Map (untuk FCM payload)
  factory NotificationItem.fromMap(Map<String, dynamic> data) {
    return NotificationItem(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? '',
      message: data['message'] ?? data['body'] ?? '',
      time: data['time'] ?? 'Baru saja',
      type: data['type'] ?? 'info',
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : DateTime.now(),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // TODO: Ganti dengan data dari FCM/Firestore
  // Untuk sementara masih pakai data placeholder
  // Saat FCM terintegrasi, gunakan StreamBuilder dengan Firestore notifications collection
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // TODO: Implementasi load dari Firestore/FCM
    // Contoh: 
    // final stream = FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userId)
    //     .collection('notifications')
    //     .orderBy('createdAt', descending: true)
    //     .snapshots();
    
    // Untuk sementara, tampilkan empty state
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _notifications = []; // Kosongkan, tidak ada notifikasi dummy
        _isLoading = false;
      });
    }
  }

  void _markAllAsRead() {
    // TODO: Update di Firestore
    setState(() {
      _notifications = _notifications.map((n) => NotificationItem(
        id: n.id,
        title: n.title,
        message: n.message,
        time: n.time,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            _buildEmbeddedHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      );
    }

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
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
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
      body: _buildBody(),
    );
  }

  Widget _buildEmbeddedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Notifications',
            style: GoogleFonts.lobster(
              color: const Color(0xFF1E3A5F),
              fontSize: 22,
            ),
          ),
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                "Mark all read",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFE67E22),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildNotificationCard(_notifications[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: const Color(0xFFE67E22).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi pesanan dan promo\nakan muncul di sini',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    // Tentukan warna dan icon berdasarkan tipe notifikasi
    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    switch (item.type) {
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
        color: item.isRead ? Colors.white : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: item.isRead 
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
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E3A5F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.time,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
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
