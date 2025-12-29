import 'package:flutter/material.dart';
import 'package:orderly/old/core/config/user_context.dart';
import 'package:orderly/old/features/admin/menu_management/menu_management_page.dart';
import 'package:orderly/old/features/admin/staff_management/staff_page.dart';
import 'package:orderly/old/features/admin/table_management/table_page.dart';
import '../../core/config/supabase_client.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0; // 0=Menu, 1=Tavoli, 2=Staff

  @override
  Widget build(BuildContext context) {
    final user = UserContext.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin – ${user?.restaurantName ?? ''} (${user?.staffName ?? ''})',
        ),
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
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.restaurant_menu), label: Text('Menu')),
              NavigationRailDestination(
                  icon: Icon(Icons.table_bar), label: Text('Tavoli')),
              NavigationRailDestination(
                  icon: Icon(Icons.people), label: Text('Staff')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const MenuManagementPage();
      case 1:
        return const TablePage();
      case 2:
        return const StaffPage();
      default:
        return const SizedBox.shrink();
    }
  }
}
