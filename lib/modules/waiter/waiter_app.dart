import 'package:flutter/material.dart';
import 'dart:async';

// Importazioni Config & Dati
import '../../../config/themes.dart';
import '../../../data/mock_data.dart'; // Accesso a globalTables
import '../../../data/models/table_item.dart';
import '../../../data/models/cart_item.dart';

// Importazioni Schermate
import 'screens/login_screen.dart';
import 'screens/menu_view.dart';
import 'screens/success_view.dart';
import 'screens/tables_view.dart';

class WaiterApp extends StatefulWidget {
  const WaiterApp({super.key});

  @override
  State<WaiterApp> createState() => _WaiterAppState();
}

class _WaiterAppState extends State<WaiterApp> {
  // Stato iniziale: LOGIN
  String _currentView = 'login';
  TableItem? _selectedTable;

  // --- LOGICA DI NAVIGAZIONE ---

  void _handleLoginSuccess() {
    setState(() {
      _currentView = 'tables';
    });
  }

  void _handleLogout() {
    setState(() {
      _currentView = 'login';
      _selectedTable = null;
    });
  }

  void _goToTables() {
    setState(() {
      _currentView = 'tables';
      _selectedTable = null;
    });
  }

  void _goToMenu(TableItem table) {
    setState(() {
      _selectedTable = table;
      _currentView = 'menu';
    });
  }

  void _goToSuccess() {
    setState(() {
      _currentView = 'success';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _goToTables();
    });
  }

  // --- LOGICA DI BUSINESS (Gestione Tavoli) ---

  void _handleTableMove(TableItem source, TableItem target) {
    setState(() {
      target.status = 'occupied';
      target.guests = source.guests;
      target.orders = List.from(source.orders);

      source.status = 'free';
      source.guests = 0;
      source.orders = [];
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tavolo spostato con successo"))
    );
  }

  void _handleTableMerge(TableItem source, TableItem target) {
    setState(() {
      target.guests += source.guests;
      target.orders.addAll(source.orders);

      source.status = 'free';
      source.guests = 0;
      source.orders = [];
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tavoli uniti con successo"))
    );
  }

  void _handlePayment(TableItem table, List<CartItem> paidItems) {
    setState(() {
      for (var paid in paidItems) {
        final originalIndex = table.orders.indexWhere((o) => o.internalId == paid.internalId);
        if (originalIndex != -1) {
          table.orders[originalIndex].qty -= paid.qty;
        }
      }
      table.orders.removeWhere((o) => o.qty <= 0);

      if (table.orders.isEmpty) {
        table.status = 'free';
        table.guests = 0;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.cEmerald500,
          content: Text("Pagamento registrato con successo"),
          duration: Duration(seconds: 2),
        )
    );
  }

  void _onOrderSent(List<CartItem> newOrders) {
    setState(() {
      if (_selectedTable != null) {
        _selectedTable!.orders.addAll(newOrders);
        if (newOrders.isNotEmpty || _selectedTable!.orders.isNotEmpty) {
          _selectedTable!.status = 'occupied';
        }
      }
    });
    _goToSuccess();
  }

  // --- BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cSlate900,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              color: AppColors.cSlate50,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)
              ]
          ),
          child: _buildCurrentView(),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'login':
        return LoginScreen(onLoginSuccess: _handleLoginSuccess);
      case 'tables':
        return TablesView(
          tables: globalTables,
          onTableSelected: _goToMenu,
          onMoveTable: _handleTableMove,
          onMergeTable: _handleTableMerge,
          onPayment: _handlePayment,
          onLogout: _handleLogout,
        );
      case 'menu':
        if (_selectedTable == null) return const SizedBox();
        return MenuView(
          table: _selectedTable!,
          onBack: _goToTables,
          onSuccess: _onOrderSent,
        );
      case 'success':
        return SuccessView(
          tableName: _selectedTable?.name ?? "",
        );
      default:
        return const Center(child: Text("Errore: Vista non trovata"));
    }
  }
}