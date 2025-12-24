import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/core/config/user_context.dart';
import 'package:orderly/shared/widgets/loading_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_client.dart';
import '../orders/orders_models.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  final user = UserContext.instance;

  bool loading = true;
  List<Order> currentOrders = [];
  List<Order> completedOrders = [];
  int selectedIndex = 0; // Tracks the selected rail

  StreamSubscription? _ordersSubscription;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() => loading = true);

    try {
      final response = await supabase
      .functions.invoke('get_orders_with_staff', method: HttpMethod.get);

      List<Order> allOrders = (response.data['orders'] as List).map((o) => Order.fromMap(o)).toList();
      currentOrders = allOrders.where((o) => !['completed', 'cancelled'].contains(o.status)).toList();
      completedOrders = allOrders.where((o) => o.status == 'completed').toList();
    } catch (e) {
      _showSnackBar('Errore caricamento ordini cucina: $e');
    }

    print('[Cucina] Ordini caricati: ${currentOrders.length} attuali, ${completedOrders.length} completati.');

    if (mounted) setState(() => loading = false);
  }

  void _subscribeRealtime() {
    _ordersSubscription = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('restaurant_id', user!.restaurantId)
        .listen((_) {
      _fetchOrders();
      print('[Cucina] Aggiornamento ordini ricevuto in realtime.');
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cucina'),
        actions: [
          IconButton(
            onPressed: () async {
              await _fetchOrders();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              context.go('/staff');
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.kitchen),
                label: Text('Ordini Attuali'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.check_circle),
                label: Text('Ordini Completati'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: loading
                ? const LoadingWidget()
                : selectedIndex == 0
                ? _buildOrderList(currentOrders)
                : _buildOrderList(completedOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('Nessun ordine disponibile.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (_, index) {
        final order = orders[index];
        return KitchenOrderCard(
          order: order,
          onAdvanceStatus: selectedIndex == 0
              ? () => _advanceOrderStatus(order)
              : (){}, // Disable advancing status for completed orders
        );
      },
    );
  }

  Future<void> _advanceOrderStatus(Order order) async {
    final next = _nextStatus(order.status);

    print('[Cucina] Avanzamento stato ordine ${order.id} da ${order.status} a $next');

    try {
      await supabase.functions.invoke('update_order_status', body: {
        'order_id': order.id,
        'status': next,
      });
    } catch (e) {
      _showSnackBar('Errore aggiornamento stato $e');
    }
  }

  String _nextStatus(String current) {
    switch (current) {
      case 'pending':
        return 'preparing';
      case 'preparing':
        return 'ready';
      case 'ready':
        return 'completed';
      default:
        return current;
    }
  }
}

/* ============================================================
   =============== KITCHEN ORDER CARD =========================
   ============================================================ */

class KitchenOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onAdvanceStatus;

  const KitchenOrderCard({
    super.key,
    required this.order,
    required this.onAdvanceStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.status;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              tableName: order.tableName,
              status: status,
            ),

            if (order.orderNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              _OrderNotes(order.orderNotes),
            ],

            const SizedBox(height: 12),

            _ItemsList(items: order.items),

            const SizedBox(height: 12),

            if (status != 'completed')
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onAdvanceStatus,
                  child: Text(_nextStatusLabel(status)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _nextStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Inizia preparazione';
      case 'preparing':
        return 'Segna come pronto';
      case 'ready':
        return 'Completa ordine';
      default:
        return '';
    }
  }
}

class _Header extends StatelessWidget {
  final String? tableName;
  final String status;

  const _Header({
    required this.tableName,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tavolo ${tableName ?? '-'}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        _StatusBadge(status),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;

    switch (status) {
      case 'pending':
        color = Colors.grey;
        label = 'In attesa';
        break;
      case 'preparing':
        color = Colors.orange;
        label = 'In preparazione';
        break;
      case 'ready':
        color = Colors.green;
        label = 'Pronto';
        break;
      default:
        color = Colors.blueGrey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _OrderNotes extends StatelessWidget {
  final String notes;

  const _OrderNotes(this.notes);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning, color: Colors.yellow),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notes,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsList extends StatelessWidget {
  final List<OrderItemDraft> items;

  const _ItemsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'x${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ItemContent(item: item),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ItemContent extends StatelessWidget {
  final OrderItemDraft item;

  const _ItemContent({required this.item});

  @override
  Widget build(BuildContext context) {
    final notes = item.notes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.dish.name,
          style: const TextStyle(fontSize: 15),
        ),
        if (notes != null && notes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              notes,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.redAccent,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
