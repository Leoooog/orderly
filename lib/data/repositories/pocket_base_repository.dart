import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:orderly/data/models/config/department.dart';
import 'package:orderly/data/models/config/table.dart';
import 'package:orderly/data/models/config/void_reason.dart';
import 'package:orderly/data/models/enums/table_status.dart';
import 'package:orderly/data/models/local/cart_entry.dart';
import 'package:orderly/data/models/menu/allergen.dart';
import 'package:orderly/data/models/menu/category.dart';
import 'package:orderly/data/models/menu/course.dart';
import 'package:orderly/data/models/menu/menu_item.dart';
import 'package:orderly/data/models/session/order.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../core/services/tenant_service.dart';
import '../models/config/restaurant.dart';
import '../models/enums/order_item_status.dart';
import '../models/menu/extra.dart';
import '../models/menu/ingredient.dart';
import '../models/session/table_session.dart';
import '../models/user.dart';
import 'i_orderly_repository.dart';

class PocketBaseRepository implements IOrderlyRepository {
  late PocketBase _pb;

  // Private constructor to force use of the `create` factory method
  PocketBaseRepository._(String baseUrl) {
    _pb = PocketBase(baseUrl);
  }

  // Async factory method for creation
  static Future<PocketBaseRepository> create() async {
    final tenantService = await TenantService.create();
    final url = tenantService.getSavedTenantUrl();
    if (url == null) {
      throw Exception(
          "No saved tenant URL. Cannot initialize PocketBaseRepository.");
    }
    return PocketBaseRepository._(url);
  }

  // --- AUTH & CONFIG ---
  @override
  Future<User> loginWithPin(String pin) async {
    try {
      final bytes = utf8.encode(pin);
      final hash = sha256.convert(bytes).toString();

      final result = await _pb.collection('users').getList(
            filter: 'pin_hash = "$hash"',
            perPage: 1,
          );

      if (result.items.isEmpty) {
        throw Exception('Invalid PIN');
      }
      return User.fromJson(result.items.first.toJson());
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<Restaurant> getRestaurantInfo() async {
    final records = await _pb.collection('restaurants').getList(perPage: 1);
    if (records.items.isNotEmpty) {
      return Restaurant.fromJson(records.items.first.toJson());
    }
    throw Exception('Restaurant configuration not found');
  }

  // --- MASTER DATA ---
  @override
  Future<List<Table>> getTables() async {
    final records = await _pb.collection('tables').getFullList(sort: 'name');
    return records.map((r) => Table.fromJson(r.toJson())).toList();
  }

  @override
  Future<List<Category>> getCategories() async {
    final records =
        await _pb.collection('categories').getFullList(sort: 'display_order');
    return records.map((r) => Category.fromJson(r.toJson())).toList();
  }

  @override
  Future<List<MenuItem>> getMenuItems() async {
    final records = await _pb.collection('menu_items').getFullList(
        expand: 'category,allergens,extras,ingredients,produced_by');
    return records.map((r) {
      MenuItem item = MenuItem.fromJson(r.toJson());
      Category? category =
          Category.fromJson(r.toJson()['expand']?['category'] ?? {});
      List<Allergen> allergens =
          (r.toJson()['expand']?['allergens'] as List<dynamic>?)
                  ?.map((e) => Allergen.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];
      List<Ingredient> ingredients =
          (r.toJson()['expand']?['ingredients'] as List<dynamic>?)
                  ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];
      List<Extra> extras = (r.toJson()['expand']?['extras'] as List<dynamic>?)
              ?.map((e) => Extra.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      List<Department> producedBy = (r.toJson()['expand']?['produced_by'] !=
              null)
          ? [
              Department.fromJson(
                  r.toJson()['expand']!['produced_by'] as Map<String, dynamic>)
            ]
          : [];

      return item.copyWith(
          category: category,
          allergens: allergens,
          ingredients: ingredients,
          allowedExtras: extras,
          producedBy: producedBy);
    }).toList();
  }

  @override
  Future<List<Course>> getCourses() async {
    final records =
        await _pb.collection('courses').getFullList(sort: 'display_order');
    return records.map((r) => Course.fromJson(r.toJson())).toList();
  }

  @override
  Future<List<Department>> getDepartments() async {
    final records = await _pb.collection('departments').getFullList();
    return records.map((r) => Department.fromJson(r.toJson())).toList();
  }

  @override
  Future<List<VoidReason>> getVoidReasons() async {
    final records = await _pb.collection('void_reasons').getFullList();
    return records.map((r) => VoidReason.fromJson(r.toJson())).toList();
  }

  // --- REALTIME STREAMS ---

  @override
  Stream<List<TableSession>> watchActiveSessions() {
    // Usiamo uno StreamController per convertire le callback di PB in Stream Dart
    final controller = StreamController<List<TableSession>>();
    List<TableSession> currentList = [];

    // 1. Fetch Iniziale: Scarichiamo subito lo stato attuale
    _pb
        .collection('table_sessions')
        .getFullList(
          filter: 'status != "closed"', // Ci interessano solo quelle aperte
          sort: '-created',
        )
        .then((records) {
      currentList =
          records.map((r) => TableSession.fromJson(r.toJson())).toList();
      if (!controller.isClosed) controller.add(currentList);
    }).catchError((e) {
      if (!controller.isClosed) controller.addError(e);
    });

    // 2. Sottoscrizione Realtime
    // Nota: Sottoscriviamo a '*' (tutti gli eventi) per gestire correttamente
    // il caso in cui una sessione venga chiusa (update status -> closed).
    // Se filtrassimo lato server, potremmo non ricevere l'evento di chiusura.
    _pb.collection('table_sessions').subscribe('*', (e) {
      if (controller.isClosed) return;

      final record = e.record;
      if (record == null) return;

      final item = TableSession.fromJson(record.toJson());
      final isClosed = item.status == TableSessionStatus.closed;

      if (e.action == 'delete' || isClosed) {
        // RIMUOVI: Se è stata cancellata o chiusa, via dalla lista
        currentList.removeWhere((i) => i.id == item.id);
      } else {
        // AGGIUNGI/AGGIORNA:
        final index = currentList.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          currentList[index] = item; // Aggiorna esistente
        } else {
          currentList.add(item); // Nuova sessione aperta
        }
      }

      // Emetti la nuova lista aggiornata
      controller.add(List.from(currentList));
    });

    // 3. Cleanup: Quando nessuno ascolta più, stacca la socket
    controller.onCancel = () {
      _pb.collection('table_sessions').unsubscribe('*');
    };

    return controller.stream;
  }

  @override
  Stream<List<Order>> watchActiveOrders() {
    final controller = StreamController<List<Order>>();
    List<Order> currentList = [];

    // Filtro: Solo ordini creati oggi (Active Service)
    // '@todayStart' è una macro comodissima di PocketBase
    const filter = 'created >= "@todayStart"';

    // 1. Fetch Iniziale
    _pb
        .collection('orders')
        .getFullList(
          filter: filter,
          sort: '-created',
        )
        .then((records) {
      currentList = records.map((r) => Order.fromJson(r.toJson())).toList();
      if (!controller.isClosed) controller.add(currentList);
    }).catchError((e) {
      if (!controller.isClosed) controller.addError(e);
    });

    // 2. Realtime
    _pb.collection('orders').subscribe('*', (e) {
      if (controller.isClosed) return;
      if (e.record == null) return;

      final item = Order.fromJson(e.record!.toJson());

      // Gestione CRUD locale
      if (e.action == 'delete') {
        currentList.removeWhere((i) => i.id == item.id);
      } else {
        final index = currentList.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          currentList[index] = item;
        } else {
          // Aggiungiamo in cima (ordinamento temporale)
          currentList.insert(0, item);
        }
      }

      controller.add(List.from(currentList));
    }, filter: filter); // Qui possiamo usare il filtro anche in sottoscrizione

    controller.onCancel = () {
      _pb.collection('orders').unsubscribe('*');
    };

    return controller.stream;
  }

  // Helper to get current sessions once
  Future<List<TableSession>> getActiveSessions() async {
    final records = await _pb.collection('table_sessions').getFullList(
          filter: 'status != "closed"',
          expand: 'table,waiter',
        );
    return records.map((r) => TableSession.fromJson(r.toJson())).toList();
  }

  // --- ACTIONS ---
  @override
  Future<void> openTable(String tableId, int guests, String waiterId) async {
    final body = {
      'table': tableId,
      'guests_count': guests,
      'waiter': waiterId,
      'status': 'seated',
    };
    await _pb.collection('table_sessions').create(body: body);
  }

  @override
  Future<void> closeTableSession(String sessionId) async {
    await _pb
        .collection('table_sessions')
        .update(sessionId, body: {'status': 'closed'});
  }

  @override
  Future<void> sendOrder(
      {required String sessionId,
      required String waiterId,
      required List<CartEntry> items}) async {
    // This is a complex transaction and should ideally be a single API call to the backend.
    // Simulating it on the client is prone to errors.
    // 1. Create the main Order
    final orderBody = {
      'session': sessionId,
      'waiter': waiterId,
      'status': 'pending', // Or based on logic
    };
    final orderRecord = await _pb.collection('orders').create(body: orderBody);

    // 2. Create each OrderItem and link it to the Order
    for (final entry in items) {
      final itemBody = {
        'order': orderRecord.id,
        'menu_item': entry.item.id,
        'quantity': entry.quantity,
        'notes': entry.notes,
        'status': 'pending',
        'extras': entry.selectedExtras.map((e) => e.id).toList(),
      };
      await _pb.collection('order_items').create(body: itemBody);
    }
  }

  @override
  Future<void> voidItem(
      {required String orderItemId,
      required VoidReason reason,
      required int quantity,
      required bool refund,
      required String voidedBy,
      String? notes}) async {
    // Again, this should be a single backend transaction.
    final body = {
      'order_item': orderItemId,
      'reason': reason.id,
      'quantity': quantity,
      'is_refunded': refund,
      'notes': notes,
      'voided_by': voidedBy,
    };
    await _pb.collection('voids').create(body: body);
    // The backend should have a trigger to update the original order_item's quantity or status.
  }

  @override
  Future<void> moveTable(String sourceSessionId, String targetTableId) async {
    await _pb
        .collection('table_sessions')
        .update(sourceSessionId, body: {'table': targetTableId});
  }

  @override
  Future<void> mergeTable(
      String sourceSessionId, String targetSessionId) async {
    // This is highly complex and should be a custom backend endpoint.
    // e.g., POST /api/custom/merge-tables
    // Body: { "source": "...", "target": "..." }
    // The backend would then move all orders and close the source session.
    // Client-side simulation is not safe.
    throw UnimplementedError(
        'Table merging must be handled by a custom backend endpoint.');
  }

  @override
  Future<void> processPayment(
      String tableSessionId, List<String> orderItemIds) async {
    // Complex logic, ideal for a backend endpoint.
    // e.g., POST /api/custom/process-payment
    // Body: { "session": "...", "items": [...], "method": "..." }
    throw UnimplementedError(
        'Payment processing should be a custom backend endpoint.');
  }

  @override
  Future<void> updateOrderItemStatus(
      String orderItemId, OrderItemStatus status) async {
    await _pb
        .collection('order_items')
        .update(orderItemId, body: {'status': status.name});
  }

  @override
  Future<void> updateOrderItem(
      {required String orderItemId,
      required int newQty,
      required String newNotes,
      required Course newCourse,
      required List<Extra> newExtras,
      required List<Ingredient> newRemovedIngredients}) async {
    final body = {
      'quantity': newQty,
      'notes': newNotes,
      'selected_extras': newExtras.map((e) => e.id).toList(),
      'removed_ingredients': newRemovedIngredients.map((e) => e.id).toList(),
      'course': newCourse.id,
    };
    await _pb.collection('order_items').update(orderItemId, body: body);
  }
}
