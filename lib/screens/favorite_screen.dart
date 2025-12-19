import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.cake),
            title: Text('Double Chocolate Cookie'),
            trailing: Icon(Icons.favorite, color: Colors.red),
          ),
          ListTile(
            leading: Icon(Icons.cake),
            title: Text('Almond Cookie'),
            trailing: Icon(Icons.favorite, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
