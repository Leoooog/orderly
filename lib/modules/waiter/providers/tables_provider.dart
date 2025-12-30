import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/table_item.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/course.dart';
import '../../../data/mock_data.dart';

final tablesProvider = NotifierProvider<TablesNotifier, List<TableItem>>(TablesNotifier.new);

class TablesNotifier extends Notifier<List<TableItem>> {

  @override
  List<TableItem> build() {
    return globalTables;
  }

  // ... (Metodi occupyTable, addOrdersToTable, moveTable, mergeTable, processPayment rimangono uguali a prima) ...
  // Li ometto per brevità ma devono esserci nel file finale.

  // Riscrivo quelli rilevanti per questa modifica:

  void occupyTable(int tableId, int guests) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          TableItem(id: table.id, name: table.name, status: 'occupied', guests: guests, orders: table.orders)
        else
          table
    ];
  }

  void addOrdersToTable(int tableId, List<CartItem> newOrders) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          TableItem(id: table.id, name: table.name, status: 'occupied', guests: table.guests, orders: [...table.orders, ...newOrders])
        else
          table
    ];
  }

  // --- NUOVI METODI PER GESTIONE PORTATE ---

  // 1. DARE IL VIA (Waiter -> Kitchen)
  void fireCourse(int tableId, Course course) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _updateItemsStatus(table, (item) => item.course == course && item.status == ItemStatus.pending, ItemStatus.fired)
        else
          table
    ];

    // SIMULAZIONE: Dopo 3 secondi la cucina finisce i piatti!
    // In un'app vera questo non ci sarebbe, arriverebbe una push notification.
    Future.delayed(const Duration(seconds: 3), () {
      mockKitchenReady(tableId, course);
    });
  }

  // 2. SIMULAZIONE CUCINA (Kitchen -> Waiter)
  void mockKitchenReady(int tableId, Course course) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _updateItemsStatus(table, (item) => item.course == course && item.status == ItemStatus.fired, ItemStatus.ready)
        else
          table
    ];
  }

  // 3. SEGNA COME SERVITO (Waiter -> System)
  void markAsServed(int tableId, int itemInternalId) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _updateItemsStatus(table, (item) => item.internalId == itemInternalId, ItemStatus.served)
        else
          table
    ];
  }

  // Helper generico per aggiornare status
  TableItem _updateItemsStatus(TableItem table, bool Function(CartItem) condition, ItemStatus newStatus) {
    final updatedOrders = table.orders.map((item) {
      if (condition(item)) {
        return item.copyWith(status: newStatus);
      }
      return item;
    }).toList();

    return TableItem(
        id: table.id,
        name: table.name,
        status: table.status,
        guests: table.guests,
        orders: updatedOrders
    );
  }

  // Per completezza, includo i metodi di business critici minimi per far compilare se copi-incolli tutto
  void processPayment(int tableId, List<CartItem> paidItems) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _calculateRemaining(table, paidItems)
        else
          table
    ];
  }

  TableItem _calculateRemaining(TableItem table, List<CartItem> paidItems) {
    final remaining = List<CartItem>.from(table.orders);
    for (var paid in paidItems) {
      final index = remaining.indexWhere((o) => o.internalId == paid.internalId);
      if (index != -1) remaining[index].qty -= paid.qty;
    }
    remaining.removeWhere((o) => o.qty <= 0);
    return TableItem(id: table.id, name: table.name, status: remaining.isEmpty ? 'free' : 'occupied', guests: remaining.isEmpty ? 0 : table.guests, orders: remaining);
  }

  void moveTable(int sId, int tId) { /* ... logica move ... */ }
  void mergeTable(int sId, int tId) { /* ... logica merge ... */ }
}