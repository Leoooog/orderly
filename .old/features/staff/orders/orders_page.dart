import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/old/core/config/user_context.dart';
import 'package:orderly/old/shared/widgets/loading_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_client.dart';
import 'orders_models.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final user = UserContext.instance;

  bool loading = true;
  List<Order> orders = [];

  final double maxDragOffset = 70.0;
  double dragOffset = 0.0; // Tracks the drag distance
  bool isRefreshing = false; // Tracks if a refresh is in progress

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => loading = true);

    try {
      final response = await supabase
          .functions.invoke('get_orders_with_staff', method: HttpMethod.get);


      orders = (response.data['orders'] as List).map((o) => Order.fromMap(o)).where((o) => !['completed', 'cancelled'].contains(o.status)).toList();
    } catch (e) {
      _showSnackBar('Errore caricamento ordini: $e');
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordini'),
        actions: [
          IconButton(
              onPressed: () async {
                await fetchOrders();
              },
              icon: Icon(Icons.refresh)),
          IconButton(
              onPressed: () {
                context.go('/staff');
              },
              icon: Icon(Icons.arrow_back))
        ],
      ),
      body: loading ? LoadingWidget() : _buildOrderList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await _tablesAvailable() == false) {
            _showSnackBar("Nessun tavolo disponibile.");
            return;
          }

          final result = await context.push('/staff/orders/new');
          if (result == true) {
            setState(() {
              loading = true;
              fetchOrders();
              _showSnackBar("Ordine creato");
            });
          }
        },
        tooltip: 'Nuovo Ordine',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOrderList() {
    return Stack(
      children: [
        GestureDetector(
          onVerticalDragUpdate: (details) {
            setState(() {
              dragOffset = min(maxDragOffset, dragOffset + details.delta.dy);
            });
          },
          onVerticalDragEnd: (_) async {
            if (dragOffset >= maxDragOffset) {
              setState(() {
                isRefreshing = true;
              });
              await fetchOrders();
              setState(() {
                isRefreshing = false;
              });
            }
            setState(() {
              dragOffset = 0.0;
            });
          },
          child: Transform.translate(
            offset: Offset(0, dragOffset),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orders.isEmpty ? 1 : orders.length,
              itemBuilder: (_, index) {
                if (orders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('Nessun ordine disponibile.'),
                    ),
                  );
                }
                final order = orders[index];
                return ListTile(
                  leading: const Icon(Icons.table_bar),
                  onTap: () async {
                    await _updateOrder(order.id);
                  },
                  title: Text('Tavolo ${order.tableName}'),
                  subtitle: Text(order.status),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(order.staffName),
                      IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await _updateOrder(order.id);
                          }),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteOrder(order),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (dragOffset > 0 || isRefreshing)
          Positioned(
            top: min(dragOffset - 50, 0),
            left: 0,
            right: 0,
            child: Center(
              child: isRefreshing
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.refresh, size: 30),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDeleteOrder(Order order) async {
    final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Conferma eliminazione'),
            content: Text(
              'Sei sicuro di voler eliminare l\'ordine per il tavolo "${order.tableName}"?\n\nQuesta operazione è irreversibile.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Elimina'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await _deleteOrder(order);
    }
  }

  Future<void> _deleteOrder(Order order) async {
    try {
      setState(() {
        loading = true;
      });
      await supabase.functions.invoke(
        'delete_order',
        body: {'order_id': order.id},
      );
      fetchOrders();
      _showSnackBar("Ordine eliminato");
    } catch (e) {
      _showSnackBar('Errore eliminazione ordine: $e');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<bool> _tablesAvailable() async {
    final response = await supabase
        .from('tables')
        .select('id')
        .eq('restaurant_id', user!.restaurantId)
        .eq('status', 'available')
        .limit(1);

    return (response as List).isNotEmpty;
  }

  Future<void> _updateOrder(int orderId) async {
    final result = await context.push('/staff/orders/$orderId');
    if (result == true) {
      await fetchOrders();
      _showSnackBar("Ordine aggiornato");
    }
  }
}
