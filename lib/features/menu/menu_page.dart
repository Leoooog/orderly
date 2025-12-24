import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key, required restaurantId, required tableId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Page'),
      ),
      body: Center(
        child: Text('This is the Menu Page'),
      ),
    );
  }
}