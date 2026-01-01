import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import '../../../config/hive_keys.dart';
import '../../../data/models/enums/order_item_status.dart';
import '../../../data/models/enums/table_status.dart';
import '../../../data/models/session/order_item.dart';
import '../../../data/models/session/table_session.dart';
import '../../../data/models/session/void_record.dart';
import '../../../data/models/table_item.dart';
import '../../../data/models/order_item.dart';
import '../../../data/models/course.dart';
import '../../../data/models/void_record.dart';
import '../../../data/models/extra.dart';
import '../../../data/mock_data.dart';


final tablesProvider = NotifierProvider<TablesNotifier, List<TableSession>>(TablesNotifier.new);

class TablesNotifier extends Notifier<List<TableSession>> {

  late Box _tablesBox;
  late Box _voidsBox;

  @override
  List<TableSession> build() {
    _tablesBox = Hive.box<dynamic>(kTablesBox);
    _voidsBox = Hive.box<dynamic>(kVoidsBox);
    return _loadFromDisk();
  }

  // --- PERSISTENZA ---
  List<TableSession> _loadFromDisk() {
    final dynamic data = _tablesBox.get(kTablesKey);
    List<TableSession> loadedTables;

    if (data != null && data is List) {
      loadedTables = data.map((e) => TableSession.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      loadedTables = globalTables;
    }

    // SANITIZZAZIONE: Ricalcola lo stato corretto per ogni tavolo caricato.
    // Questo corregge discrepanze tra lo stato salvato (es. 'seated') e gli ordini presenti (es. lista piena).
    final sanitizedTables = loadedTables.map((t) {
      if (t.status == TableStatus.free) return t;
      return t.copyWith(
          status: _calculateTableStatus(t.status, t.orders)
      );
    }).toList();

    // Se erano dati mock (primo avvio), salviamo subito la versione corretta/sanitizzata
    if (data == null) {
      _saveToDisk(sanitizedTables);
    }

    return sanitizedTables;
  }

  void _saveToDisk(List<TableSession> tables) {
    final jsonList = tables.map((t) => t.toJson()).toList();
    _tablesBox.put(kTablesKey, jsonList);
  }

  @override
  set state(List<TableSession> newState) {
    super.state = newState;
    _saveToDisk(newState);
  }

  // --- LOGICA MACRO-STATO TAVOLO ---
  TableStatus _calculateTableStatus(TableStatus currentStatus, List<OrderItem> orders) {
    if (currentStatus == TableStatus.free) return TableStatus.free;
    if (orders.isEmpty) return TableStatus.seated;

    if (orders.any((o) => o.status == OrderItemStatus.ready)) {
      return TableStatus.ready;
    }

    if (orders.any((o) => o.status == OrderItemStatus.pending || o.status == OrderItemStatus.fired || o.status == OrderItemStatus.cooking)) {
      return TableStatus.ordered;
    }

    if (orders.every((o) => o.status == OrderItemStatus.served)) {
      return TableStatus.eating;
    }

    return currentStatus;
  }

  // --- LETTURA STORNI ---
  List<VoidRecord> getVoidsForTable(int tableId) {
    if (!Hive.isBoxOpen(kVoidsBox)) return [];

    // Filtriamo i log salvati nel box
    final allVoids = _voidsBox.values.map((e) => VoidRecord.fromJson(Map<String, dynamic>.from(e))).toList();
    return allVoids.where((v) => v.tableId == tableId).toList();
  }

  TableSession getTableById(int tableId) {
    return state.firstWhere((t) => t.id == tableId);
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

  void addOrdersToTable(int tableId, List<OrderItem> newOrders) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _updateTableWithNewOrders(table, newOrders)
        else
          table
    ];
  }

  TableSession _updateTableWithNewOrders(TableSession table, List<OrderItem> newOrders) {
    // Creiamo una copia mutabile degli ordini attuali
    final List<OrderItem> currentOrders = List.from(table.orders);

    // Iteriamo sui nuovi ordini per tentare il merge
    for (var newOrder in newOrders) {
      // Cerchiamo un ordine esistente IDENTICO (stesso prodotto, note, corso, extra e stato)
      final existingIndex = currentOrders.indexWhere((o) =>
      o.id == newOrder.id &&
          o.notes == newOrder.notes &&
          o.course == newOrder.course &&
          o.status == newOrder.status && // Solitamente 'pending' appena inviato
          _areExtrasEqual(o.selectedExtras, newOrder.selectedExtras)
      );

      if (existingIndex != -1) {
        // MERGE: Incrementiamo la quantità dell'ordine esistente
        currentOrders[existingIndex] = currentOrders[existingIndex].copyWith(
            qty: currentOrders[existingIndex].qty + newOrder.qty
        );
      } else {
        // NUOVO: Aggiungiamo il nuovo ordine alla lista
        currentOrders.add(newOrder);
      }
    }

    return table.copyWith(
      orders: currentOrders,
      status: _calculateTableStatus(table.status, currentOrders),
    );
  }

  // --- MODIFICA ORDINE ESISTENTE (SPLIT & MERGE LOGIC) ---
  void updateOrderedItem(int tableId, int itemInternalId, int qtyToModify, String newNote, Course newCourse, List<Extra> newExtras) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _performUpdateItem(table, itemInternalId, qtyToModify, newNote, newCourse, newExtras)
        else
          table
    ];
  }

  TableSession _performUpdateItem(TableSession table, int itemInternalId, int qtyToModify, String newNote, Course newCourse, List<Extra> newExtras) {
    final index = table.orders.indexWhere((i) => i.internalId == itemInternalId);
    if (index == -1) return table;

    final originalItem = table.orders[index];

    // Validazione
    if (qtyToModify <= 0 || qtyToModify > originalItem.qty) return table;

    // 1. Se non è cambiato nulla, esci
    if (originalItem.notes == newNote &&
        originalItem.course == newCourse &&
        _areExtrasEqual(originalItem.selectedExtras, newExtras)) {
      return table;
    }

    // Creiamo una copia modificabile della lista attuale
    final List<OrderItem> updatedOrders = List.from(table.orders);

    if (qtyToModify < originalItem.qty) {
      // CASO A: SPLIT PARZIALE (Modifico solo una parte)

      // 1. Riduco l'originale
      updatedOrders[index] = originalItem.copyWith(qty: originalItem.qty - qtyToModify);

      // 2. Creo il nuovo item con le modifiche
      final newItem = originalItem.copyWith(
          internalId: DateTime.now().millisecondsSinceEpoch,
          qty: qtyToModify,
          notes: newNote,
          course: newCourse,
          selectedExtras: newExtras
        // Lo status viene ereditato (es. pending)
      );

      // 3. Provo a unirlo se esiste già un gemello
      _mergeOrAdd(updatedOrders, newItem);

    } else {
      // CASO B: UPDATE TOTALE (Modifico tutto il blocco)

      // 1. Rimuovo l'originale temporaneamente
      updatedOrders.removeAt(index);

      // 2. Preparo l'item aggiornato
      final updatedItem = originalItem.copyWith(
          notes: newNote,
          course: newCourse,
          selectedExtras: newExtras
      );

      // 3. Provo a unirlo o lo reinserisco
      _mergeOrAdd(updatedOrders, updatedItem, insertAt: index);
    }

    return table.copyWith(orders: updatedOrders);
  }

  // Helper per unire o aggiungere alla lista
  void _mergeOrAdd(List<OrderItem> orders, OrderItem newItem, {int? insertAt}) {
    // Cerchiamo un target identico per il merge
    final mergeTargetIndex = orders.indexWhere((o) =>
    o.id == newItem.id &&
        o.notes == newItem.notes &&
        o.course == newItem.course &&
        o.status == newItem.status &&
        _areExtrasEqual(o.selectedExtras, newItem.selectedExtras)
    );

    if (mergeTargetIndex != -1) {
      // MERGE: Incrementa quantità esistente
      orders[mergeTargetIndex] = orders[mergeTargetIndex].copyWith(
          qty: orders[mergeTargetIndex].qty + newItem.qty
      );
    } else {
      // CREATE: Aggiungi nuovo
      if (insertAt != null && insertAt <= orders.length) {
        orders.insert(insertAt, newItem); // Mantieni posizione originale se possibile
      } else {
        orders.add(newItem);
      }
    }
  }

  // Helper per confrontare extras
  bool _areExtrasEqual(List<Extra> a, List<Extra> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.id).toSet();
    final bIds = b.map((e) => e.id).toSet();
    return aIds.containsAll(bIds);
  }

  // --- GESTIONE PORTATE & CUCINA ---

  void fireCourse(int tableId, Course course) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _updateItemsInTable(table,
                  (item) => item.course == course && item.status == OrderItemStatus.pending,
              OrderItemStatus.fired
          )
        else
          table
    ];


    Future.delayed(const Duration(seconds: 5), () {
      mockKitchenStatus(tableId, course, OrderItemStatus.fired, OrderItemStatus.cooking);
    });
    Future.delayed(const Duration(seconds: 10), () {
      mockKitchenStatus(tableId, course, OrderItemStatus.cooking, OrderItemStatus.ready);
    });

  }

  void mockKitchenStatus(int tableId, Course course, OrderItemStatus fromStatus, OrderItemStatus toStatus) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _updateItemsInTable(table,
                  (item) => item.course == course && item.status == fromStatus,
              toStatus
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
              OrderItemStatus.served
          )
        else
          table
    ];
  }

  // --- STORNO (VOID) ---

  void voidItem(int tableId, int itemInternalId, int qtyToVoid, String reason, bool isRefunded) {
    final tableIndex = state.indexWhere((t) => t.id == tableId);
    if (tableIndex == -1) return;

    final table = state[tableIndex];
    final item = table.orders.firstWhere((i) => i.internalId == itemInternalId);

    // 1. Salva log storno
    final voidLog = VoidRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tableId: tableId,
      tableName: table.name,
      itemName: item.name,
      unitPrice: item.unitPrice,
      quantity: qtyToVoid,
      statusWhenVoided: item.status,
      reason: reason,
      isRefunded: isRefunded,
      timestamp: DateTime.now(),
    );

    _voidsBox.add(voidLog.toJson());
    // 2. Aggiorna stato tavolo
    state = [
      for (final t in state)
        if (t.id == tableId)
          _performVoidOnTable(t, itemInternalId, qtyToVoid)
        else
          t
    ];
  }

  TableSession _performVoidOnTable(TableSession table, int itemInternalId, int qtyToVoid) {
    final updatedOrders = List<OrderItem>.from(table.orders);
    final index = updatedOrders.indexWhere((i) => i.internalId == itemInternalId);

    if (index != -1) {
      final item = updatedOrders[index];
      if (item.qty <= qtyToVoid) {
        updatedOrders.removeAt(index);
      } else {
        updatedOrders[index] = item.copyWith(qty: item.qty - qtyToVoid);
      }
    }

    return table.copyWith(
      orders: updatedOrders,
      status: _calculateTableStatus(table.status, updatedOrders),
    );
  }

  // --- GESTIONE TAVOLI E PAGAMENTI ---

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

  TableSession _performMerge(TableSession target, TableSession source) {
    final combinedOrders = [...target.orders, ...source.orders];
    return target.copyWith(
      guests: target.guests + source.guests,
      orders: combinedOrders,
      status: _calculateTableStatus(TableStatus.ordered, combinedOrders),
    );
  }

  TableSession _updateItemsInTable(TableSession table, bool Function(OrderItem) condition, OrderItemStatus newStatus) {
    final updatedOrders = table.orders.map((item) {
      return condition(item) ? item.copyWith(status: newStatus) : item;
    }).toList();

    return table.copyWith(
      orders: updatedOrders,
      status: _calculateTableStatus(table.status, updatedOrders),
    );
  }

  void processPayment(int tableId, List<OrderItem> paidItems) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _calculateRemaining(table, paidItems)
        else
          table
    ];
  }

  TableSession _calculateRemaining(TableSession table, List<OrderItem> paidItems) {
    final remaining = List<OrderItem>.from(table.orders);
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

  void cancelTable(int tableId) {
    state = [
      for (final table in state)
        if (table.id == tableId)
        // Resetta completamente il tavolo
          table.copyWith(
              status: TableStatus.free,
              guests: 0,
              orders: []
          )
        else
          table
    ];
  }
}