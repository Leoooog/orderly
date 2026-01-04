import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/config/table.dart';
import 'package:orderly/data/models/config/void_reason.dart';
import 'package:orderly/data/models/enums/order_item_status.dart';
import 'package:orderly/data/models/enums/table_status.dart';
import 'package:orderly/data/models/local/cart_entry.dart';
import 'package:orderly/data/models/local/table_model.dart';
import 'package:orderly/data/models/menu/course.dart';
import 'package:orderly/data/models/menu/extra.dart';
import 'package:orderly/data/models/menu/ingredient.dart';
import 'package:orderly/data/models/session/order.dart';
import 'package:orderly/data/models/session/table_session.dart';
import 'package:orderly/data/repositories/i_orderly_repository.dart';

// Importa il repository provider
import 'package:orderly/logic/providers/repository_provider.dart';
import 'package:orderly/logic/providers/session_provider.dart';

import '../../../data/models/session/order_item.dart';
import 'menu_provider.dart';

// -----------------------------------------------------------------------------
// PROVIDERS DI DATI GREZZI (OTTIMIZZATI)
// -----------------------------------------------------------------------------

final tablesListProvider = FutureProvider<List<Table>>((ref) async {
  print("[tablesListProvider] fetching tables...");
  // Attende che il repository sia pronto
  final repository = await ref.watch(repositoryProvider.future);
  if (repository == null) {
    throw Exception(
        "Repository non inizializzato. Impossibile fetchare tables.");
  }
  return repository.getTables();
});

/// Stream delle sessioni APERTE.
final activeSessionsStreamProvider =
    StreamProvider<List<TableSession>>((ref) async* {
  print("[activeSessionsStreamProvider] setting up stream...");
  // async* ci permette di aspettare il future prima di fare yield dello stream
  final repository = await ref.watch(repositoryProvider.future);
  if (repository == null) {
    throw Exception(
        "Repository non inizializzato. Impossibile watch active sessions.");
  }
  yield* repository.watchActiveSessions();
});

/// Stream degli ordini ATTIVI (del turno corrente).
final activeOrdersStreamProvider = StreamProvider<List<Order>>((ref) async* {
  print("[activeOrdersStreamProvider] setting up stream...");
  final repository = await ref.watch(repositoryProvider.future);
  if (repository == null) {
    throw Exception(
        "Repository non inizializzato. Impossibile watch active orders.");
  }
  yield* repository.watchActiveOrders();
});

/// Stream di TUTTI gli item attivi.
final activeOrderItemsStreamProvider =
    StreamProvider<List<OrderItem>>((ref) async* {
  print("[activeOrderItemsStreamProvider] setting up stream...");
  final repository = await ref.watch(repositoryProvider.future);
  if (repository == null) {
    throw Exception(
        "Repository non inizializzato. Impossibile watch active order items.");
  }
  yield* repository.watchAllActiveOrderItems();
});

// -----------------------------------------------------------------------------
// CONTROLLER: Business Logic & Data Joining
// -----------------------------------------------------------------------------

final tablesControllerProvider =
    AsyncNotifierProvider<TablesController, List<TableUiModel>>(
        TablesController.new);

class TablesController extends AsyncNotifier<List<TableUiModel>> {
  // Helper per ottenere l'ID utente corrente dallo stato della sessione
  String get _currentUserId {
    final sessionState = ref.read(sessionProvider).value;
    if (sessionState == null) {
      throw Exception("Sessione non inizializzata in tablesController.");
    }
    final user = sessionState.currentUser;
    if (user == null) {
      throw Exception("Utente non autenticato in tablesController.");
    }
    return user.id;
  }

  IOrderlyRepository get _repository {
    final repo = ref.read(repositoryProvider).value;
    if (repo == null) {
      throw Exception(
          "Repository non inizializzato. Impossibile eseguire l'operazione in tablesController.");
    }
    return repo;
  }

  @override
  Future<List<TableUiModel>> build() async {
    print("[TablesController] Building TableUiModels...");
    // 1. Fetch dei tavoli (Configurazione statica)
    final tables = await ref.watch(tablesListProvider.future);

    // 2. Fetch dei dati Real-time (Sessioni, Ordini, Items)
    // USANDO .future SUGLI STREAM:
    // Il controller rimarrà in stato "Loading" finché TUTTI questi stream
    // non avranno emesso il primo valore. Niente più "tavoli vuoti" temporanei.
    final sessionList = await ref.watch(activeSessionsStreamProvider.future);
    final orderList = await ref.watch(activeOrdersStreamProvider.future);
    final allItems = await ref.watch(activeOrderItemsStreamProvider.future);

    // Se siamo arrivati qui, significa che abbiamo TUTTI i dati.
    // Possiamo procedere direttamente con la logica di unione.

    // 3. Group items by order ID
    final Map<String, List<OrderItem>> itemsByOrderId = {};
    for (final item in allItems) {
      (itemsByOrderId[item.orderId] ??= []).add(item);
    }

    // 4. Enrich orders
    final enrichedOrders = orderList.map((order) {
      final liveItems = itemsByOrderId[order.id] ?? [];
      return order.copyWith(items: liveItems);
    }).toList();

    // 5. Group orders by session ID
    final Map<String, List<Order>> ordersBySessionId = {};
    for (final order in enrichedOrders) {
      (ordersBySessionId[order.sessionId] ??= []).add(order);
    }

    // 6. Build UI Models
    final uiModels = tables.map((table) {
      final session = sessionList.firstWhere(
        (s) => s.tableId == table.id,
        orElse: () => TableSession.empty(),
      );

      // Se non c'è sessione, è libero
      if (session.isEmpty) {
        return TableUiModel(table: table, status: TableStatus.free);
      }

      final liveOrders = ordersBySessionId[session.id] ?? [];
      // Sort orders: newest first
      liveOrders.sort((a, b) => b.created.compareTo(a.created));

      final enrichedSession = session.copyWith(orders: liveOrders);
      final sessionStatus = _calculateSessionStatus(enrichedSession);

      return TableUiModel(
        table: table,
        status: TableStatus.occupied, // O usa logica custom se preferisci
        activeSession: enrichedSession,
        sessionStatus: sessionStatus,
      );
    }).toList();

    uiModels.sort((a, b) => a.table.name.compareTo(b.table.name));

    return uiModels;
  }

  TableSessionStatus _calculateSessionStatus(TableSession session) {
    if (session.orders.isEmpty) return TableSessionStatus.seated;
    final allItems = session.orders.expand((o) => o.items).toList();
    if (allItems.isEmpty) return TableSessionStatus.seated;

    if (allItems.any((item) => item.status == OrderItemStatus.ready)) {
      return TableSessionStatus.ready;
    }
    if (allItems.any((item) =>
        item.status == OrderItemStatus.pending ||
        item.status == OrderItemStatus.fired ||
        item.status == OrderItemStatus.cooking)) {
      return TableSessionStatus.ordered;
    }
    if (allItems.every((item) => item.status == OrderItemStatus.served)) {
      return TableSessionStatus.eating;
    }
    return TableSessionStatus.ordered;
  }

  // --- ACTIONS ---

  Future<TableSession?> openTable(String tableId, int guests) async {
    state = const AsyncLoading();
    try {
      final session = await _repository.openTable(tableId, guests, _currentUserId);
      return session;
    } catch (e, st) {
      state = AsyncError(e, st);
    }
    return null;
  }

  Future<void> closeTable(String sessionId) async {
    state = const AsyncLoading();
    try {
      await _repository.closeTableSession(sessionId);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> sendOrder(String sessionId, List<CartEntry> items) async {
    if (items.isEmpty) return;
    state = const AsyncLoading();
    try {
      await _repository.sendOrder(
        sessionId: sessionId,
        waiterId: _currentUserId,
        items: items,
      );
    } catch (e, st) {
      state = AsyncError(e, st);
      print("[TablesController][sendOrder] Error: $e");
      rethrow; // Rilancia per la UI (Snackbar, Dialogs)
    }
  }

  Future<void> voidOrderItem(
      {required OrderItem orderItem,
      required String tableSessionId,
      required VoidReason reason,
      required bool refund,
      required int quantity,
      String? notes}) async {
    state = const AsyncLoading();
    try {
      final menuItem = await ref
          .read(menuItemsProvider.notifier)
          .getMenuItemById(orderItem.menuItemId);
      final amount = orderItem.priceEach * quantity;

      await _repository.voidItem(
        orderItemId: orderItem.id,
        reason: reason,
        tableSessionId: tableSessionId,
        menuItemId: orderItem.menuItemId,
        menuItemName: menuItem.name,
        amount: amount,
        quantity: quantity,
        refund: refund,
        voidedBy: _currentUserId,
        statusWhenVoided: orderItem.status,
        notes: notes,
      );
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> moveTable(String sourceSessionId, String targetTableId) async {
    state = const AsyncLoading();
    try {
      await _repository.moveTable(sourceSessionId, targetTableId);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> mergeTables(
      String sourceSessionId, String targetSessionId) async {
    // Nota: Merge non implementato nel _repository, ma qui lo predisponiamo

    await _repository.mergeTable(sourceSessionId, targetSessionId);
  }

  Future<void> processPayment(
      String tableSessionId, List<String> orderItemIds) async {
    await _repository.processPayment(tableSessionId, orderItemIds);
  }

  Future<void> fireCourse(String sessionId, String courseId) async {
    final table = getTableBySessionId(sessionId);
    if (table?.activeSession == null) return;

    // Logica ottimistica client-side
    final itemsToFire = table!.activeSession!.orders
        .expand((order) => order.items)
        .where((item) =>
            item.course.id == courseId &&
            item.status == OrderItemStatus.pending &&
            item.requiresFiring)
        .toList();

    print("[fireCourse] Firing ${itemsToFire.length} items for course $courseId in session $sessionId");

    final ids = itemsToFire.map((item) => item.id).toList();
    print("[fireCourse] Item IDs to fire: $ids");

    if(itemsToFire.isEmpty) return;

     await _repository.updateOrderItemStatus(ids, OrderItemStatus.fired);
  }

  Future<void> markAsServed(String orderItemId) async {
    await _repository.updateOrderItemStatus(
        [orderItemId], OrderItemStatus.served);
  }

  Future<void> recallOrderItem(String orderItemId) async {
    await _repository.updateOrderItemStatus(
        [orderItemId], OrderItemStatus.pending);
  }

  Future<void> updateOrderItemDetails({
    required String orderItemId,
    required int newQty,
    required String newNotes,
    required Course newCourse,
    required List<Extra> newExtras,
    required List<Ingredient> newRemovedIngredients,
  }) async {
    await _repository.updateOrderItem(
      orderItemId: orderItemId,
      newQty: newQty,
      newNotes: newNotes,
      newCourse: newCourse,
      newExtras: newExtras,
      newRemovedIngredients: newRemovedIngredients,
    );
  }

  TableUiModel? getTableBySessionId(String sessionId) {
    return state.value?.firstWhere(
      (table) => table.sessionId == sessionId,
      orElse: () => TableUiModel.empty(),
    );
  }
}
