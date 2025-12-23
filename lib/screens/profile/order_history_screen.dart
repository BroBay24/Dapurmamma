import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Bolu Coklat Kacang'),
            subtitle: Text('Rp 35.000'),
            trailing: Text('Selesai'),
          ),
          ListTile(
            title: Text('Bolu Coklat Durian'),
            subtitle: Text('Rp 45.000'),
            trailing: Text('Selesai'),
          ),
        ],
      ),
    );
  }
}
