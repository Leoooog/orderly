import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/core/config/user_context.dart';
import 'package:orderly/features/admin/table_management/table_models.dart';
import '../../../core/config/supabase_client.dart';
import '../../admin/menu_management/menu_models.dart';
import 'orders_models.dart';

class OrderPage extends StatefulWidget {
  final int? orderId;

  const OrderPage({super.key, this.orderId});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final user = UserContext.instance;

  bool loading = true;

  int? selectedTableId;
  final TextEditingController orderNotesController = TextEditingController();

  List<RestaurantTable> tables = [];
  List<Category> categories = [];
  List<Dish> allDishes = [];
  final List<OrderItemDraft> items = [];
  late Order order;

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null) {
      fetchOrderDetails(widget.orderId!);
    } else {
      fetchData();
    }
  }

  Future<void> fetchOrderDetails(int orderId) async {
    setState(() => loading = true);

    try {
      final response = await supabase
          .from('orders_with_staff')
          .select('*, order_items(dish_id, quantity, notes, dishes(*))')
          .eq('id', orderId)
          .single();
      order = Order.fromMap(response);
      selectedTableId = order.tableId;
      orderNotesController.text = order.orderNotes;
      items.addAll(order.items.map((item) => OrderItemDraft(
            dish: item.dish,
            quantity: item.quantity,
            notes: item.notes,
          )));

      await fetchData(); // Fetch tables and dishes
    } catch (e) {
      _showSnackBar('Errore durante il caricamento: $e');
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> fetchData() async {
    setState(() => loading = true);

    try {
      // Fetch tables
      final tableRes = await supabase
          .from('tables')
          .select('id, name, status')
          .eq('restaurant_id', user!.restaurantId)
          .eq('status', 'available')
          .order('name');

      tables =
          (tableRes as List).map((t) => RestaurantTable.fromMap(t)).toList();

      // Fetch categories
      final catRes = await supabase
          .from('categories')
          .select()
          .eq('restaurant_id', user!.restaurantId)
          .order('name');

      categories = (catRes as List).map((c) => Category.fromMap(c)).toList();

      // Fetch dishes
      final dishRes = await supabase
          .from('dishes')
          .select()
          .eq('restaurant_id', user!.restaurantId);

      allDishes = (dishRes as List).map((d) => Dish.fromMap(d)).toList();

      for (var cat in categories) {
        cat.dishes = allDishes.where((d) => d.categoryId == cat.id).toList();
        cat.dishes.sort((a, b) => a.name.compareTo(b.name));
      }
    } catch (e) {
      _showSnackBar('Errore durante il caricamento: $e');
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.orderId == null
              ? 'Nuovo Ordine'
              : 'Modifica Ordine ${loading ? '' : '#${order.id} del tavolo ${order.tableName}'}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.orderId == null) _buildHeader(),
                const Divider(),
                Expanded(child: _buildDishList()),
                _buildOrderNotesField(),
              ],
            ),
      bottomSheet: items.isEmpty ? null : _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DropdownButtonFormField<int>(
        initialValue: selectedTableId,
        hint: const Text('Seleziona tavolo'),
        items: tables
            .map(
              (t) => DropdownMenuItem<int>(
                value: t.id,
                child: Text(t.name),
              ),
            )
            .toList(),
        onChanged: widget.orderId == null
            ? (v) => setState(() => selectedTableId = v)
            : null,
        // Disable dropdown if editing an order
        decoration: InputDecoration(
          labelText:
              widget.orderId == null ? 'Tavolo' : 'Tavolo (non modificabile)',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDishList() {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (_, index) {
        final category = categories[index];
        return ExpansionTile(
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: category.dishes.map(_buildDishTile).toList(),
        );
      },
    );
  }

  Widget _buildDishTile(Dish dish) {
    final existing = items.where((i) => i.dish.id == dish.id).firstOrNull;

    return ListTile(
      title: Text(dish.name),
      subtitle: Text('€${dish.price.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (existing != null) ...[
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _decrementDish(dish),
            ),
            Text(
              existing.quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _incrementDish(dish),
            ),
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: () => _showNotesDialog(existing),
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _incrementDish(dish),
            ),
        ],
      ),
      onTap: () => _incrementDish(dish),
    );
  }

  void _incrementDish(Dish dish) {
    final existing = items.where((i) => i.dish.id == dish.id).firstOrNull;

    setState(() {
      if (existing != null) {
        existing.quantity++;
      } else {
        items.add(OrderItemDraft(dish: dish));
      }
    });
  }

  void _decrementDish(Dish dish) {
    final existing = items.where((i) => i.dish.id == dish.id).firstOrNull;

    if (existing != null) {
      setState(() {
        if (existing.quantity > 1) {
          existing.quantity--;
        } else {
          items.remove(existing);
        }
      });
    }
  }

  void _showNotesDialog(OrderItemDraft item) {
    final notesController = TextEditingController(text: item.notes);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Note per ${item.dish.name}'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            hintText: 'Aggiungi note',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                item.notes = notesController.text.trim();
              });
              context.pop();
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNotesField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: orderNotesController,
        decoration: const InputDecoration(
          labelText: 'Note per l\'ordine',
          border: OutlineInputBorder(),
        ),
        maxLines: 2,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _submitOrder,
          child: Text(widget.orderId == null
              ? 'Invia ordine (${items.length})'
              : 'Aggiorna ordine (${items.length})'),
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (loading) return;
    if (selectedTableId == null || items.isEmpty) {
      _showSnackBar('Seleziona tavolo e almeno un piatto');
      return;
    }

    try {
      final body = {
        'restaurant_id': user!.restaurantId,
        'table_id': selectedTableId,
        'items': items
            .map((i) => {
                  'dish_id': i.dish.id,
                  'quantity': i.quantity,
                  'notes': i.notes,
                })
            .toList(),
        'order_notes': orderNotesController.text.trim(),
      };

      if (widget.orderId == null) {
        // Create new order
        setState(() {
          loading = true;
        });
        await supabase.functions.invoke('create_order', body: body);
        setState(() {
          loading = false;
        });
      } else {
        // Update existing order
        await supabase.functions.invoke('update_order', body: {
          ...body,
          'order_id': widget.orderId,
        });
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar(
          'Errore ${widget.orderId == null ? "creazione" : "modifica"} ordine: $e');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
