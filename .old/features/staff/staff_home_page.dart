import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/old/core/config/supabase_client.dart';

import '../../core/config/user_context.dart';

class StaffHomePage extends StatelessWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserContext.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Staff – ${user?.restaurantName ?? ''} (${user?.staffName ?? ''})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Mostra conferma
              final confirmed = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  title:
                  const Text('Conferma Log Out'),
                  content: Text(
                    'Sei sicuro di voler uscire?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: const Text('Annulla'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () =>
                          Navigator.pop(context, true),
                      child: const Text('Esci'),
                    ),
                  ],
                ),
              ) ??
                  false;

              if (!confirmed) return;

              // Log out
              await supabase.auth.signOut();

            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ORDINI (waiter)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text('Gestione ordini'),
                onPressed: () {
                  context.go('/staff/orders');
                },
              ),
            ),
            const SizedBox(height: 16),

            // CUCINA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.restaurant),
                label: const Text('Cucina'),
                onPressed: () {
                  context.go('/staff/kitchen');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
