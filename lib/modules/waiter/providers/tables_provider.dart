import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import '../../../data/hive_keys.dart';
import '../../../data/models/table_item.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/course.dart';
import '../../../data/mock_data.dart';

final tablesProvider = NotifierProvider<TablesNotifier, List<TableItem>>(TablesNotifier.new);

class TablesNotifier extends Notifier<List<TableItem>> {
  late Box _box;

  @override
  List<TableItem> build() {
    _box = Hive.box(kTablesBox);
    return _loadFromDisk();
  }

  // --- PERSISTENZA ---

  List<TableItem> _loadFromDisk() {
    final dynamic data = _box.get(kTablesKey);
    if (data != null && data is List) {
      return data.map((e) => TableItem.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    _saveToDisk(globalTables);
    return globalTables;
  }

  void _saveToDisk(List<TableItem> tables) {
    final jsonList = tables.map((t) => t.toJson()).toList();
    _box.put(kTablesKey, jsonList);
  }

  @override
  set state(List<TableItem> newState) {
    super.state = newState;
    _saveToDisk(newState);
  }

  // --- LOGICA MACRO-STATO TAVOLO ---

  TableStatus _calculateTableStatus(TableStatus currentStatus, List<CartItem> orders) {
    if (currentStatus == TableStatus.free) return TableStatus.free;
    if (orders.isEmpty) return TableStatus.seated;

    if (orders.any((o) => o.status == ItemStatus.ready)) {
      return TableStatus.ready;
    }

    if (orders.any((o) => o.status == ItemStatus.pending || o.status == ItemStatus.fired || o.status == ItemStatus.cooking)) {
      return TableStatus.ordered;
    }

    if (orders.every((o) => o.status == ItemStatus.served)) {
      return TableStatus.eating;
    }

    return currentStatus;
  }

  // --- AZIONI ---

  void occupyTable(int tableId, int guests) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          table.copyWith(status: TableStatus.seated, guests: guests)
        else
          table
    ];
  }

  void addOrdersToTable(int tableId, List<CartItem> newOrders) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _updateTableWithNewOrders(table, newOrders)
        else
          table
    ];
  }

  TableItem _updateTableWithNewOrders(TableItem table, List<CartItem> newOrders) {
    final updatedOrders = [...table.orders, ...newOrders];
    return table.copyWith(
      orders: updatedOrders,
      status: _calculateTableStatus(table.status, updatedOrders),
    );
  }

  void fireCourse(int tableId, Course course) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _updateItemsInTable(table,
                  (item) => item.course == course && item.status == ItemStatus.pending,
              ItemStatus.fired
          )
        else
          table
    ];

    // Simuliamo il tempo di preparazione in cucina

    // Dopo 2 secondi, gli elementi passano a "cooking"
    Future.delayed(const Duration(seconds: 5), () => mockKitchenCooking(tableId, course));
    // Dopo 4 secondi, gli elementi passano a "ready"
    Future.delayed(const Duration(seconds: 5), () => mockKitchenReady(tableId, course));
  }

  void mockKitchenReady(int tableId, Course course) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _updateItemsInTable(table,
                  (item) => item.course == course && item.status == ItemStatus.cooking,
              ItemStatus.ready
          )
        else
          table
    ];
  }

  mockKitchenCooking(int tableId, Course course) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _updateItemsInTable(table,
                  (item) => item.course == course && item.status == ItemStatus.fired,
              ItemStatus.cooking
          )
        else
          table
    ];
  }

  void markAsServed(int tableId, int itemInternalId) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _updateItemsInTable(table,
                  (item) => item.internalId == itemInternalId,
              ItemStatus.served
          )
        else
          table
    ];
  }

  void moveTable(int sourceId, int targetId) {
    final sourceTable = state.firstWhere((t) => t.id == sourceId);

    state = [
      for (final table in state)
        if (table.id == targetId)
          table.copyWith(
            status: sourceTable.status,
            guests: sourceTable.guests,
            orders: List.from(sourceTable.orders),
          )
        else if (table.id == sourceId)
          table.copyWith(status: TableStatus.free, guests: 0, orders: [])
        else
          table
    ];
  }

  void mergeTable(int sourceId, int targetId) {
    final sourceTable = state.firstWhere((t) => t.id == sourceId);

    state = [
      for (final table in state)
        if (table.id == targetId)
          _performMerge(table, sourceTable)
        else if (table.id == sourceId)
          table.copyWith(status: TableStatus.free, guests: 0, orders: [])
        else
          table
    ];
  }

  TableItem _performMerge(TableItem target, TableItem source) {
    final combinedOrders = [...target.orders, ...source.orders];
    return target.copyWith(
      guests: target.guests + source.guests,
      orders: combinedOrders,
      status: _calculateTableStatus(TableStatus.ordered, combinedOrders),
    );
  }

  TableItem _updateItemsInTable(TableItem table, bool Function(CartItem) condition, ItemStatus newStatus) {
    final updatedOrders = table.orders.map((item) {
      return condition(item) ? item.copyWith(status: newStatus) : item;
    }).toList();

    return table.copyWith(
      orders: updatedOrders,
      status: _calculateTableStatus(table.status, updatedOrders),
    );
  }

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
      if (index != -1) {
        remaining[index] = remaining[index].copyWith(qty: remaining[index].qty - paid.qty);
      }
    }
    remaining.removeWhere((o) => o.qty <= 0);

    return table.copyWith(
      orders: remaining,
      status: remaining.isEmpty ? TableStatus.free : _calculateTableStatus(table.status, remaining),
      guests: remaining.isEmpty ? 0 : table.guests,
    );
  }

}