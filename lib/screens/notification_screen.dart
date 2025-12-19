import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Pembayaran Telah Diterima'),
            subtitle: Text('Jumat, 15:45 WIB'),
          ),
          ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text('Pesanan di Batalkan'),
            subtitle: Text('Senin, 22:51 WIB'),
          ),
        ],
      ),
    );
  }
}
