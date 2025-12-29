import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orderly')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Entra con Email'),
                onPressed: () {
                  GoRouter.of(context).go('/admin_login');
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text('Entra con QR'),
                onPressed: () {
                  GoRouter.of(context).go('/staff_login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
