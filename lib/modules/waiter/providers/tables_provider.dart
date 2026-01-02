// -----------------------------------------------------------------------------
// PROVIDERS DI DATI GREZZI
// -----------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/config/void_reason.dart';
import 'package:orderly/data/models/local/cart_entry.dart';
import 'package:orderly/logic/providers/session_provider.dart';

import '../../../data/models/config/table.dart';
import '../../../data/models/enums/order_item_status.dart';
import '../../../data/models/enums/table_status.dart';
import '../../../data/models/menu/course.dart';
import '../../../data/models/menu/extra.dart';
import '../../../data/models/menu/ingredient.dart';
import '../../../data/models/session/order.dart';
import '../../../data/models/session/table_session.dart';
import '../../../data/models/local/table_model.dart';
import '../../../data/repositories/i_orderly_repository.dart';


final tablesListProvider = FutureProvider<List<Table>>((ref) async {
   return ref.watch(sessionProvider).repository!.getTables();
});


/// Stream delle sessioni APERTE.
/// Il repository deve ritornare solo le sessioni con status != 'closed'.
final activeSessionsStreamProvider = StreamProvider<List<TableSession>>((ref) {
  final repository = ref.watch(sessionProvider).repository!;
  return repository.watchActiveSessions();
});

/// Stream degli ordini ATTIVI (del turno corrente).
/// Questo stream serve per popolare le sessioni in tempo reale.
final activeOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(sessionProvider).repository!.watchActiveOrders();
});

// -----------------------------------------------------------------------------
// CONTROLLER: Business Logic & Data Joining
// -----------------------------------------------------------------------------

final tablesControllerProvider =
    AsyncNotifierProvider<TablesController, List<TableUiModel>>(
        TablesController.new);

class TablesController extends AsyncNotifier<List<TableUiModel>> {
  // Getter for convenience
  IOrderlyRepository get _repository => ref.read(sessionProvider).repository!;
  String get _currentUserId => ref.read(sessionProvider).currentUser!.id;

  @override
  Future<List<TableUiModel>> build() async {
    // 1. Watch all data sources. Riverpod will handle re-running `build` when any of them change.
    final tables = await ref.watch(tablesListProvider.future);
    final sessions = ref.watch(activeSessionsStreamProvider);
    final allOrders = ref.watch(activeOrdersStreamProvider);

    // Using .when to safely handle the loading/error states of the streams
    return sessions.when(
      data: (sessionList) {
        return allOrders.when(
          data: (orderList) {
            // 2. Join the data sources into the UI model
            final uiModels = tables.map((table) {
              final session = sessionList.firstWhere(
                (s) => s.tableId == table.id,
                orElse: () => TableSession.empty(),
              );

              if (session.isEmpty) {
                return TableUiModel(
                    table: table, status: TableStatus.free);
              }

              // Enrich the session with its orders
              final sessionOrders =
                  orderList.where((o) => o.sessionId == session.id).toList();
              sessionOrders.sort((a, b) => b.created.compareTo(a.created));

              final enrichedSession = session.copyWith(orders: sessionOrders);

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
          },
          loading: () => [], // Or return previous state if available
          error: (e, st) => throw e,
        );
      },
      loading: () => [],
      error: (e, st) => throw e,
    );
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
      await _repository.openTable(tableId, guests, _currentUserId);
      // Non serve refresh manuale: lo stream aggiornerà la UI
    } catch (e, st) {
      state = AsyncError(e, st);
    }
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
      // Anche qui, activeOrdersStreamProvider rileverà il nuovo ordine
      // e il controller ricalcolerà il build() automaticamente.
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow; // Rilanciamo per gestire errori UI (es. snackbar)
    }
  }

  Future<void> voidOrderItem(
      {required String orderItemId,
      required VoidReason reason,
      required bool refund,
      required int quantity,
      String? notes}) async {
    state = const AsyncLoading();

    try {
      await _repository.voidItem(
        orderItemId: orderItemId,
        reason: reason,
        refund: refund,
        quantity: quantity,
        voidedBy: _currentUserId,
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
    await _repository.mergeTable(sourceSessionId, targetSessionId);
  }

  Future<void> processPayment(
      String tableSessionId, List<String> orderItemIds) async {
    await _repository.processPayment(tableSessionId, orderItemIds);
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
      await _repository.updateOrderItemStatus(item.id, OrderItemStatus.fired);
    }
  }

  Future<void> markAsServed(String orderItemId) async {
    await _repository.updateOrderItemStatus(
        orderItemId, OrderItemStatus.served);
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
