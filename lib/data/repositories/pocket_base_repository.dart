import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:orderly/data/models/config/department.dart';
import 'package:orderly/data/models/config/table.dart';
import 'package:orderly/data/models/config/void_reason.dart';
import 'package:orderly/data/models/enums/table_status.dart';
import 'package:orderly/data/models/local/cart_entry.dart';
import 'package:orderly/data/models/menu/category.dart';
import 'package:orderly/data/models/menu/course.dart';
import 'package:orderly/data/models/menu/menu_item.dart';
import 'package:orderly/data/models/session/order.dart';
import 'package:orderly/data/models/session/order_item.dart';
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

  // --- CONSTANTS ---
  // Espansione profonda per avere anche il tavolo dentro l'item (utile per cucina/bar)
  static const String _orderItemExpand =
      'menu_item,selected_extras,course,removed_ingredients,order.session.table';
  static const String _menuItemExpand =
      'category,allergens,allowed_extras,ingredients,produced_by';

  // Filtro unico per garantire coerenza: mostriamo tutto ciò che appartiene a sessioni non chiuse
  static const String _activeSessionFilter = "status != 'closed'";
  static const String _activeOrderFilter = "session.status != 'closed'";
  static const String _activeItemFilter = "order.session.status != 'closed'";

  PocketBaseRepository._(String baseUrl) {
    _pb = PocketBase(baseUrl);
  }

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
        await _pb.collection('categories').getFullList(sort: 'sort_order');
    return records.map((r) => Category.fromJson(r.toJson())).toList();
  }

  @override
  Future<List<MenuItem>> getMenuItems() async {
    final records = await _pb.collection('menu_items').getFullList(
          expand: _menuItemExpand,
        );
    // Usiamo fromExpandedJson per gestire le relazioni nel modello
    return records.map((r) => MenuItem.fromExpandedJson(r.toJson())).toList();
  }

  @override
  Future<List<Course>> getCourses() async {
    final records =
        await _pb.collection('courses').getFullList(sort: 'sort_order');
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
    final controller = StreamController<List<TableSession>>();
    List<TableSession> currentList = [];

    // 1. Initial Fetch
    _pb
        .collection('table_sessions')
        .getFullList(filter: _activeSessionFilter)
        .then((records) {
      if (controller.isClosed) return;
      currentList =
          records.map((r) => TableSession.fromJson(r.toJson())).toList();
      controller.add(List.from(currentList));
    }).catchError((e) {
      if (!controller.isClosed) controller.addError(e);
    });

    // 2. Realtime Subscription
    _pb.collection('table_sessions').subscribe('*', (e) {
      if (controller.isClosed || e.record == null) return;

      final item = TableSession.fromJson(e.record!.toJson());
      final isClosed = item.status == TableSessionStatus.closed;

      if (e.action == 'delete' || isClosed) {
        currentList.removeWhere((i) => i.id == item.id);
      } else {
        final index = currentList.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          currentList[index] = item;
        } else {
          currentList.add(item);
        }
      }
      controller.add(List.from(currentList));
    });

    controller.onCancel =
        () => _pb.collection('table_sessions').unsubscribe('*');
    return controller.stream;
  }

  @override
  Stream<List<Order>> watchActiveOrders() {
    final controller = StreamController<List<Order>>();
    List<Order> currentList = [];

    // 1. Initial Fetch OTTIMIZZATO (2 chiamate invece di N+1)
    Future.wait([
      _pb.collection('orders').getFullList(filter: _activeOrderFilter),
      _pb.collection('order_items').getFullList(
            filter: _activeItemFilter,
            expand: _orderItemExpand,
          ),
    ]).then((results) {
      if (controller.isClosed) return;

      final orderRecords = results[0];
      final itemRecords = results[1];

      // Parsing Items
      final allItems = itemRecords
          .map((r) => OrderItem.fromExpandedJson(r.toJson()))
          .toList();

      // Raggruppamento items per ordine (in memoria)
      final itemsByOrder = <String, List<OrderItem>>{};
      for (var item in allItems) {
        itemsByOrder.putIfAbsent(item.orderId, () => []).add(item);
      }

      // Costruzione Ordini
      currentList = orderRecords.map((r) {
        final order = Order.fromJson(r.toJson());
        return order.copyWith(items: itemsByOrder[order.id] ?? []);
      }).toList();

      controller.add(List.from(currentList));
    }).catchError((e) {
      if (!controller.isClosed) controller.addError(e);
    });

    // 2. Realtime Subscription
    _pb.collection('orders').subscribe('*', (e) async {
      if (controller.isClosed || e.record == null) return;

      Order item = Order.fromJson(e.record!.toJson());

      // Fetch ottimizzato per singolo ordine aggiornato
      final orderItems = await _getOrderItemsForOrder(item.id);
      item = item.copyWith(items: orderItems);

      if (e.action == 'delete') {
        currentList.removeWhere((i) => i.id == item.id);
      } else {
        final index = currentList.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          currentList[index] = item;
        } else {
          currentList.insert(0, item);
        }
      }
      controller.add(List.from(currentList));
    }, filter: _activeOrderFilter);

    controller.onCancel = () => _pb.collection('orders').unsubscribe('*');
    return controller.stream;
  }

  @override
  Stream<List<OrderItem>> watchAllActiveOrderItems() {
    final controller = StreamController<List<OrderItem>>();
    List<OrderItem> currentList = [];

    // 1. Initial Fetch
    _pb
        .collection('order_items')
        .getFullList(
          filter: _activeItemFilter,
          expand: _orderItemExpand,
        )
        .then((records) {
      if (controller.isClosed) return;
      currentList =
          records.map((r) => OrderItem.fromExpandedJson(r.toJson())).toList();
      controller.add(List.from(currentList));
    }).catchError((e) {
      if (!controller.isClosed) controller.addError(e);
    });

    // 2. Realtime Subscription
    _pb.collection('order_items').subscribe('*', (e) {
      if (controller.isClosed || e.record == null) return;

      // Usiamo fromExpandedJson direttamente
      final item = OrderItem.fromExpandedJson(e.record!.toJson());

      print('[Stream] Received ${e.action} for OrderItem ${item.id}');

      if (e.action == 'delete') {
        currentList.removeWhere((i) => i.id == item.id);
        print('[Stream] Removed OrderItem ${item.id}');
      } else {
        final index = currentList.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          currentList[index] = item;
        } else {
          currentList.insert(0, item);
        }
      }
      controller.add(List.from(currentList));
    },
        expand:
            _orderItemExpand); // Importante passare expand anche alla subscription

    controller.onCancel = () => _pb.collection('order_items').unsubscribe('*');
    return controller.stream;
  }

  Future<List<OrderItem>> _getOrderItemsForOrder(String orderId) async {
    final records = await _pb.collection('order_items').getFullList(
          filter: 'order = "$orderId"',
          expand: _orderItemExpand,
        );
    return records.map((r) => OrderItem.fromExpandedJson(r.toJson())).toList();
  }

  // --- ACTIONS ---
  @override
  Future<TableSession> openTable(
      String tableId, int guests, String waiterId) async {
    final sessionRecord = await _pb.collection('table_sessions').create(body: {
      'table': tableId,
      'guests_count': guests,
      'waiter': waiterId,
      'status': TableSessionStatus.seated.name,
    });
    return TableSession.fromJson(sessionRecord.toJson());
  }

  @override
  Future<void> closeTableSession(String sessionId) async {
    await _pb
        .collection('table_sessions')
        .update(sessionId, body: {'status': 'closed'});
  }

  @override
  Future<Order> sendOrder({
    required String sessionId,
    required String waiterId,
    required List<CartEntry> items,
  }) async {
    // Prepara il payload JSON da inviare all'hook
    final body = {
      'session': sessionId,
      'waiter': waiterId,
      'items': items.map((entry) {
        return {
          'menu_item': entry.item.id,
          'menu_item_name': entry.item.name,
          'price_each': entry.unitItemPrice,
          'quantity': entry.quantity,
          'notes': entry.notes,
          'course': entry.course.id,
          // Mappiamo le liste di oggetti in liste di ID
          'removed_ingredients':
              entry.removedIngredients.map((e) => e.id).toList(),
          'selected_extras': entry.selectedExtras.map((e) => e.id).toList(),
        };
      }).toList(),
    };

    try {
      // Chiama l'endpoint custom
      // send() permette di fare richieste raw all'API di PocketBase
      final response = await _pb.send(
        '/api/custom/create-order',
        method: 'POST',
        body: body,
      );

      // La risposta è un Map<String, dynamic> che rappresenta l'ordine creato
      // Poiché l'hook ritorna il record dell'ordine, possiamo deserializzarlo subito.
      // Nota: l'hook di default non espande i campi, se serve l'espansione
      // bisogna gestirla nell'hook o fare una fetch successiva.
      // Per il return di base, questo è sufficiente.
      return Order.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Gestione errori più pulita
      print("Errore invio ordine: $e");
      throw Exception("Impossibile inviare l'ordine: ${e.toString()}");
    }
  }

  @override
  Future<void> voidItem({
    required String? orderItemId,
    required VoidReason reason,
    required String tableSessionId,
    required String menuItemId,
    required String menuItemName,
    required double amount,
    required int quantity,
    required bool refund,
    required String voidedBy,
    required OrderItemStatus statusWhenVoided,
    String? notes,
  }) async {
    await _pb.collection('voids').create(body: {
      'order_item': orderItemId,
      'session': tableSessionId,
      'menu_item': menuItemId,
      'menu_item_name': menuItemName,
      'amount': amount,
      'reason': reason.id,
      'quantity': quantity,
      'is_refunded': refund,
      'notes': notes,
      'voided_by': voidedBy,
      'status_when_voided': statusWhenVoided.name,
    });
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
    throw UnimplementedError(
        'Table merging must be handled by a custom backend endpoint.');
  }

  @override
  Future<void> processPayment(
      String tableSessionId, List<String> orderItemIds) async {
    throw UnimplementedError(
        'Payment processing should be a custom backend endpoint.');
  }

  @override
  Future<void> updateOrderItemStatus(List<String> orderItemIds, OrderItemStatus status) async {
    print('Updating status for items: $orderItemIds to $status');
    await _pb.send('/api/custom/update-order-item-status', method: 'POST', body: {
      'new_status': status.name,
      'items': orderItemIds,
    });
  }

  @override
  Future<void> updateOrderItem({
    required String orderItemId,
    required int newQty,
    required String newNotes,
    required Course newCourse,
    required List<Extra> newExtras,
    required List<Ingredient> newRemovedIngredients,
  }) async {

    await _pb.send('/api/custom/edit-order-item', method: 'POST', body: {
      'item_id': orderItemId,
      'edited_quantity': newQty,
      'new_notes': newNotes,
      'new_course': newCourse.id,
      'new_selected_extras': newExtras.map((e) => e.id).toList(),
      'new_removed_ingredients':
          newRemovedIngredients.map((i) => i.id).toList(),
    });
  }


}
