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
import 'package:orderly/data/models/menu/menu_item.dart';
import 'package:orderly/data/models/session/order.dart';
import 'package:orderly/data/models/session/table_session.dart';
import 'package:orderly/data/repositories/i_orderly_repository.dart';
import 'package:orderly/logic/providers/session_provider.dart';

import '../../../data/models/session/order_item.dart';
import 'menu_provider.dart';

// -----------------------------------------------------------------------------
// PROVIDERS DI DATI GREZZI (OTTIMIZZATI)
// -----------------------------------------------------------------------------

final tablesListProvider = FutureProvider<List<Table>>((ref) async {
  // FIX: Usiamo select per ricostruire SOLO se cambia il repository (es. login/logout)
  print("[tablesListProvider] fetching tables...");
  final repository = ref.watch(sessionProvider.select((s) => s.repository));
  print("[tablesListProvider] got repository: $repository");
  if (repository == null) return [];
  return repository.getTables();
});


/// Stream delle sessioni APERTE.
final activeSessionsStreamProvider = StreamProvider<List<TableSession>>((ref) {
  // FIX: Usiamo select per evitare che lo stream venga killato e ricreato ad ogni notify della sessione
  print("[activeSessionsStreamProvider] setting up stream...");
  final repository = ref.watch(sessionProvider.select((s) => s.repository));
  if (repository == null) return Stream.value([]);
  return repository.watchActiveSessions();
});

/// Stream degli ordini ATTIVI (del turno corrente).
final activeOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  // FIX: Usiamo select anche qui
  print("[activeOrdersStreamProvider] setting up stream...");
  final repository = ref.watch(sessionProvider.select((s) => s.repository));
  if (repository == null) return Stream.value([]);
  return repository.watchActiveOrders();
});

/// Stream of ALL active order items for the current service/day.
/// This is the single source of truth for item state changes.
final activeOrderItemsStreamProvider = StreamProvider<List<OrderItem>>((ref) {
  print("[activeOrderItemsStreamProvider] setting up stream...");
  final repository = ref.watch(sessionProvider.select((s) => s.repository));
  if (repository == null) return Stream.value([]);
  return repository.watchAllActiveOrderItems();
});

// -----------------------------------------------------------------------------
// CONTROLLER: Business Logic & Data Joining
// -----------------------------------------------------------------------------

final tablesControllerProvider =
AsyncNotifierProvider<TablesController, List<TableUiModel>>(
    TablesController.new);

class TablesController extends AsyncNotifier<List<TableUiModel>> {
  // Getter for convenience
  IOrderlyRepository? get _repository => ref.read(sessionProvider).repository;
  String? get _currentUserId => ref.read(sessionProvider).currentUser?.id;

  @override
  Future<List<TableUiModel>> build() async {
    // 1. Watch all data sources.
    final tables = await ref.watch(tablesListProvider.future);
    final sessionsValue = ref.watch(activeSessionsStreamProvider);
    final ordersValue = ref.watch(activeOrdersStreamProvider);
    final allItemsValue = ref.watch(activeOrderItemsStreamProvider);

    // Handle loading and error states gracefully
    if (sessionsValue.isLoading || ordersValue.isLoading || allItemsValue.isLoading) {
      print("[TablesController] One or more streams are loading...");
      return []; // Or a specific loading state representation
    }

    if (sessionsValue.hasError) {
      print("[TablesController] Error in activeSessionsStreamProvider: ${sessionsValue.error}");
      throw sessionsValue.error!;
    }
    if (ordersValue.hasError) {
      print("[TablesController] Error in activeOrdersStreamProvider: ${ordersValue.error}");
      throw ordersValue.error!;
    }
    if (allItemsValue.hasError) {
      print("[TablesController] Error in activeOrderItemsStreamProvider: ${allItemsValue.error}");
      throw allItemsValue.error!;
    }

    // At this point, we can safely access the values.
    final sessionList = sessionsValue.value!;
    final orderList = ordersValue.value!;
    final allItems = allItemsValue.value!;

    print("[TablesController] Building UI models with "
        "${tables.length} tables, "
        "${sessionList.length} active sessions, "
        "${orderList.length} active orders, "
        "${allItems.length} active items.");

    // 1. Group all active items by their order ID for efficient lookup.
    final Map<String, List<OrderItem>> itemsByOrderId = {};
    for (final item in allItems) {
      (itemsByOrderId[item.orderId] ??= []).add(item);
      print("[TablesController] Item $item");
    }

    // 2. Enrich orders with their fully updated items from the live stream.
    final enrichedOrders = orderList.map((order) {
      final liveItems = itemsByOrderId[order.id] ?? [];
      return order.copyWith(items: liveItems);
    }).toList();

    // 3. Group the now-enriched orders by their session ID.
    final Map<String, List<Order>> ordersBySessionId = {};
    for (final order in enrichedOrders) {
      (ordersBySessionId[order.sessionId] ??= []).add(order);
    }

    // 4. Join the data sources into the final UI model.
    final uiModels = tables.map((table) {
      final session = sessionList.firstWhere(
        (s) => s.tableId == table.id,
        orElse: () => TableSession.empty(),
      );

      if (session.isEmpty) {
        return TableUiModel(table: table, status: TableStatus.free);
      }

      // Enrich the session with its fully updated orders.
      final liveOrders = ordersBySessionId[session.id] ?? [];
      liveOrders.sort((a, b) => b.created.compareTo(a.created));

      final enrichedSession = session.copyWith(orders: liveOrders);

      // Determine the detailed session status
      final sessionStatus = _calculateSessionStatus(enrichedSession);

      return TableUiModel(
        table: table,
        status: TableStatus.occupied,
        activeSession: enrichedSession,
        sessionStatus: sessionStatus,
      );
    }).toList();

    uiModels.sort((a, b) => a.table.name.compareTo(b.table.name));
    return uiModels;
  }

  /// Calculates the detailed status of an active session based on its orders.
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
    return TableSessionStatus.ordered; // Default for mixed states
  }

  // --- ACTIONS (Business Logic) ---

  Future<void> openTable(String tableId, int guests) async {
    state = const AsyncLoading();
    try {
      if (_repository == null || _currentUserId == null) throw Exception("Utente non autenticato");
      await _repository!.openTable(tableId, guests, _currentUserId!);
    } catch (e, st) {
      print(e);
      state = AsyncError(e, st);
    }
  }

  Future<void> closeTable(String sessionId) async {
    state = const AsyncLoading();
    try {
      if (_repository == null) throw Exception("Utente non autenticato");
      await _repository!.closeTableSession(sessionId);
    } catch (e, st) {
      print(e);
      state = AsyncError(e, st);
    }
  }

  Future<void> sendOrder(String sessionId, List<CartEntry> items) async {
    if (items.isEmpty) return;
    state = const AsyncLoading();

    try {
      if (_repository == null || _currentUserId == null) throw Exception("Utente non autenticato");
      await _repository!.sendOrder(
        sessionId: sessionId,
        waiterId: _currentUserId!,
        items: items,
      );
    } catch (e, st) {
      print(e);
      state = AsyncError(e, st);
      rethrow;
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
      if (_repository == null || _currentUserId == null) throw Exception("Utente non autenticato");

      MenuItem menuItem = await ref.read(menuItemsProvider.notifier).getMenuItemById(orderItem.menuItemId);
      double amount = orderItem.priceEach * quantity;
      print("Voiding item ${orderItem.id}: "
          "menuItem=${menuItem.name}, "
          "amount=$amount, "
          "quantity=$quantity, "
          "refund=$refund");
      await _repository!.voidItem(
        orderItemId: orderItem.id,
        reason: reason,
        tableSessionId: tableSessionId,
        menuItemId: orderItem.menuItemId,
        menuItemName: menuItem.name,
        amount: amount,
        quantity: quantity,
        refund: refund,
        voidedBy: _currentUserId!,
        statusWhenVoided: orderItem.status,
        notes: notes,
      );
    } catch (e, st) {
      print(e);
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> moveTable(String sourceSessionId, String targetTableId) async {
    state = const AsyncLoading();

    try {
      if (_repository == null) throw Exception("Utente non autenticato");
      await _repository!.moveTable(sourceSessionId, targetTableId);
    } catch (e, st) {
      print(e);
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> mergeTables(
      String sourceSessionId, String targetSessionId) async {
    if (_repository == null) throw Exception("Utente non autenticato");
    await _repository!.mergeTable(sourceSessionId, targetSessionId);
  }

  Future<void> processPayment(
      String tableSessionId, List<String> orderItemIds) async {
    if (_repository == null) throw Exception("Utente non autenticato");
    await _repository!.processPayment(tableSessionId, orderItemIds);
  }

  Future<void> fireCourse(String sessionId, String courseId) async {
    // This logic would typically be on the backend.
    // Here we simulate it by finding all 'pending' items for that course and updating their status.
    final table = getTableBySessionId(sessionId);
    if (table == null || table.activeSession == null) return;

    final itemsToFire = table.activeSession!.orders
        .expand((order) => order.items)
        .where((item) =>
    item.course.id == courseId &&
        item.status == OrderItemStatus.pending &&
        item.course.requiresFiring)
        .toList();

    for (final item in itemsToFire) {
      if (_repository != null) {
        await _repository!.updateOrderItemStatus(item.id, OrderItemStatus.fired);
      }
    }
  }

  Future<void> markAsServed(String orderItemId) async {
    if (_repository != null) {
      await _repository!.updateOrderItemStatus(
          orderItemId, OrderItemStatus.served);
    }
  }

  Future<void> updateOrderItemDetails({
    required String orderItemId,
    required int newQty,
    required String newNotes,
    required Course newCourse,
    required List<Extra> newExtras,
    required List<Ingredient> newRemovedIngredients,
  }) async {
    if (_repository != null) {
      await _repository!.updateOrderItem(
        orderItemId: orderItemId,
        newQty: newQty,
        newNotes: newNotes,
        newCourse: newCourse,
        newExtras: newExtras,
        newRemovedIngredients: newRemovedIngredients,
      );
    }
  }

  // --- GETTERS ---

  /// Returns a specific table model by its session ID.
  TableUiModel? getTableBySessionId(String sessionId) {
    if (state.hasValue) {
      return state.value?.firstWhere((table) => table.sessionId == sessionId,
          orElse: () => TableUiModel.empty());
    }
    return null;
  }

}
