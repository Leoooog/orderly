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
    print("[TablesController] build started");
    // 1. Watch all data sources. Riverpod will handle re-running `build` when any of them change.
    final tables = await ref.watch(tablesListProvider.future);
    final sessions = ref.watch(activeSessionsStreamProvider);
    final allOrders = ref.watch(activeOrdersStreamProvider);

    // Using .when to safely handle the loading/error states of the streams
    return sessions.when(
      data: (sessionList) {
        print("[TablesController] build: received ${sessionList.length} sessions");
        return allOrders.when(
          data: (orderList) {
            print("[TablesController] build: received ${orderList.length} orders");
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
            print("[TablesController] build finished, returning ${uiModels.length} UI models");
            return uiModels;
          },
          loading: () {
            print("[TablesController] build: orders are loading");
            return [];
          }, // Or return previous state if available
          error: (e, st) {
            print("[TablesController] build error in orders stream: $e");
            throw e;
          },
        );
      },
      loading: () {
        print("[TablesController] build: sessions are loading");
        return [];
      },
      error: (e, st) {
        print("[TablesController] build error in sessions stream: $e");
        throw e;
      },
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
    print("[TablesController] openTable: tableId=$tableId, guests=$guests");
    state = const AsyncLoading();
    try {
      await _repository.openTable(tableId, guests, _currentUserId);
      print("[TablesController] openTable successful");
      // Non serve refresh manuale: lo stream aggiornerà la UI
    } catch (e, st) {
      print("[TablesController] openTable error: $e");
      state = AsyncError(e, st);
    }
  }

  Future<void> closeTable(String sessionId) async {
    print("[TablesController] closeTable: sessionId=$sessionId");
    state = const AsyncLoading();
    try {
      await _repository.closeTableSession(sessionId);
      print("[TablesController] closeTable successful");
    } catch (e, st) {
      print("[TablesController] closeTable error: $e");
      state = AsyncError(e, st);
    }
  }

  Future<void> sendOrder(String sessionId, List<CartEntry> items) async {
    if (items.isEmpty) return;
    print("[TablesController] sendOrder: sessionId=$sessionId, items=${items.length}");
    state = const AsyncLoading();

    try {

      await _repository.sendOrder(
        sessionId: sessionId,
        waiterId: _currentUserId,
        items: items,
      );
      print("[TablesController] sendOrder successful");
      // Anche qui, activeOrdersStreamProvider rileverà il nuovo ordine
      // e il controller ricalcolerà il build() automaticamente.
    } catch (e, st) {
      print("[TablesController] sendOrder error: $e");
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
    print(
        "[TablesController] voidOrderItem: orderItemId=$orderItemId, quantity=$quantity");
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
      print("[TablesController] voidOrderItem successful");
    } catch (e, st) {
      print("[TablesController] voidOrderItem error: $e");
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> moveTable(String sourceSessionId, String targetTableId) async {
    print(
        "[TablesController] moveTable: source=$sourceSessionId, target=$targetTableId");
    state = const AsyncLoading();

    try {
      await _repository.moveTable(sourceSessionId, targetTableId);
      print("[TablesController] moveTable successful");
    } catch (e, st) {
      print("[TablesController] moveTable error: $e");
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> mergeTables(
      String sourceSessionId, String targetSessionId) async {
    print(
        "[TablesController] mergeTables: source=$sourceSessionId, target=$targetSessionId");
    await _repository.mergeTable(sourceSessionId, targetSessionId);
  }

  Future<void> processPayment(
      String tableSessionId, List<String> orderItemIds) async {
    print(
        "[TablesController] processPayment: sessionId=$tableSessionId, items=${orderItemIds.length}");
    await _repository.processPayment(tableSessionId, orderItemIds);
  }

  Future<void> fireCourse(String sessionId, String courseId) async {
    print("[TablesController] fireCourse: sessionId=$sessionId, courseId=$courseId");
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
    print(
        "[TablesController] fireCourse: fired ${itemsToFire.length} items for course $courseId");
  }

  Future<void> markAsServed(String orderItemId) async {
    print("[TablesController] markAsServed: orderItemId=$orderItemId");
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
    print("[TablesController] updateOrderItemDetails: orderItemId=$orderItemId");
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
