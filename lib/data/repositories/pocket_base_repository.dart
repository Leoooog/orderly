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
import 'package:orderly/data/models/session/order_item.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../core/services/tenant_service.dart';
import '../../core/utils/extensions.dart';
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
        await _pb.collection('categories').getFullList(sort: 'sort_order');
    print(
        "[PocketBaseRepository] Fetched ${records.length} categories from PocketBase.");
    return records.map((r) => Category.fromJson(r.toJson())).toList();
  }

  @override
  Future<List<MenuItem>> getMenuItems() async {
    final records = await _pb.collection('menu_items').getFullList(
        expand: 'category,allergens,allowed_extras,ingredients,produced_by');
    print(
        "[PocketBaseRepository] Fetched ${records.length} menu items from PocketBase.");
    return records.map((r) {
      final json = r.toJson();
      MenuItem item = MenuItem.fromJson(json);
      print("[PocketBaseRepository] MenuItem ${item.id} - name: ${item.name}");

      final expand = json['expand'] as Map<String, dynamic>? ?? {};

      Category? category = expand['category'] != null
          ? Category.fromJson(expand['category'] as Map<String, dynamic>)
          : null;

      List<Allergen> allergens = (expand['allergens'] as List<dynamic>?)
              ?.map((e) => Allergen.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      List<Ingredient> ingredients = (expand['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      List<Extra> extras = (expand['allowed_extras'] as List<dynamic>?)
              ?.map((e) => Extra.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      List<Department> producedBy = (expand['produced_by'] as List<dynamic>?)
              ?.map((e) => Department.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      final populatedItem = item.copyWith(
          category: category,
          allergens: allergens,
          ingredients: ingredients,
          allowedExtras: extras,
          producedBy: producedBy);

      print(
          "[PocketBaseRepository] Populated MenuItem: ${populatedItem.toString()}");

      return populatedItem;
    }).toList();
  }

  @override
  Future<List<Course>> getCourses() async {
    final records =
        await _pb.collection('courses').getFullList(sort: 'sort_order');
    print(
        "[PocketBaseRepository] Fetched ${records.length} courses from PocketBase.");
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
    print(
        "[PocketBaseRepository] Fetched ${records.length} void reasons from PocketBase.");
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
        .getFullList(
          filter: "(status != 'closed')",
        )
        .then((records) {
      currentList =
          records.map((r) => TableSession.fromJson(r.toJson())).toList();
      if (!controller.isClosed) {
        controller.add(List.from(currentList));
      }
    }).catchError((e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    });

    // 2. Realtime Subscription
    _pb.collection('table_sessions').subscribe('*', (e) {
      if (controller.isClosed || e.record == null) return;

      final item = TableSession.fromJson(e.record!.toJson());
      final isClosed = item.status == TableSessionStatus.closed;

      // Remove if it's deleted or has become closed
      if (e.action == 'delete' || isClosed) {
        currentList.removeWhere((i) => i.id == item.id);
      } else {
        // Add or update if it's an active session
        final index = currentList.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          currentList[index] = item; // Update existing
        } else {
          currentList.add(item); // Add new
        }
      }
      controller.add(List.from(currentList)); // Yield the updated list
    });

    // 3. Cleanup
    controller.onCancel = () {
      _pb.collection('table_sessions').unsubscribe('*');
    };

    return controller.stream;
  }

  @override
  Stream<List<Order>> watchActiveOrders() {
    final controller = StreamController<List<Order>>();
    List<Order> currentList = [];

    // created less than 24 hours ago
    const filter =
        ""; //TODO: aggiustare il filtro in base alla logica di "attivo"

    // 1. Initial Fetch
    _pb
        .collection('orders')
        .getFullList(
          filter: filter,
          expand: 'items', // Eager load items
        )
        .then((records) async {
      currentList = await Future.wait(records.map((r) async {
        Order item = Order.fromJson(r.toJson());
        List<OrderItem> orderItems = await _getOrderItemsForOrder(item.id);
        print(
            "[PocketBaseRepository] Initial fetch - order ${item.id} has ${orderItems.length} items.");

        return item.copyWith(items: orderItems);
      }).toList());

      print(
          "[PocketBaseRepository] Initial fetch of orders: ${currentList.length} orders loaded.");

      if (!controller.isClosed) {
        controller.add(List.from(currentList));
      }
    }).catchError((e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    });

    // 2. Realtime Subscription
    _pb.collection('orders').subscribe('*', (e) async {
      if (controller.isClosed || e.record == null) return;

      Order item = Order.fromJson(e.record!.toJson());

      List<OrderItem> orderItems = await _getOrderItemsForOrder(item.id);

      print(
          "[PocketBaseRepository] Realtime update for order ${item.id}: fetched ${orderItems.length} items.");
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
    }, filter: filter);

    // 3. Cleanup
    controller.onCancel = () {
      _pb.collection('orders').unsubscribe('*');
    };

    return controller.stream;
  }

  @override
  Stream<List<OrderItem>> watchAllActiveOrderItems() {
    final controller = StreamController<List<OrderItem>>();
    List<OrderItem> currentList = [];

    // We assume "active" means created today. Adjust if needed.
    final filter =
        "created >= @todayStart"; //TODO: aggiustare il filtro in base alla logica di "attivo"

    // 1. Initial Fetch
    _pb
        .collection('order_items')
        .getFullList(
          filter: filter,
          expand: 'course,extras,removed_ingredients',
        )
        .then((records) {
      currentList = records.map((r) => _populateOrderItem(r)).toList();
      if (!controller.isClosed) {
        controller.add(List.from(currentList));
      }
    }).catchError((e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    });

    // 2. Realtime Subscription
    _pb
        .collection('order_items')
        .subscribe('*', expand: 'course, extras, removed_ingredients', (e) {
      if (controller.isClosed || e.record == null) return;

      final item = _populateOrderItem(e.record!);

      if (e.action == 'delete') {
        currentList.removeWhere((i) => i.id == item.id);
      } else {
        final index = currentList.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          currentList[index] = item; // Update
        } else {
          currentList.insert(0, item); // Add new
        }
      }
      controller.add(List.from(currentList));
    });

    // 3. Cleanup
    controller.onCancel = () {
      _pb.collection('order_items').unsubscribe('*');
    };

    return controller.stream;
  }

  Future<List<OrderItem>> _getOrderItemsForOrder(String orderId) async {
    final records = await _pb.collection('order_items').getFullList(
          filter: 'order = "$orderId"',
          expand: 'menu_item,extras,course,removed_ingredients',
        );
    var items = records.map((r) {
      return _populateOrderItem(r);
    }).toList();
    return items;
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
      'total_amount': items.totalAmount,
    };
    final orderRecord = await _pb.collection('orders').create(body: orderBody);

    // 2. Create each OrderItem and link it to the Order
    for (final entry in items) {
      final itemBody = {
        'order': orderRecord.id,
        'menu_item': entry.item.id,
        'menu_item_name': entry.item.name,
        'price_each': entry.unitItemPrice,
        'quantity': entry.quantity,
        'notes': entry.notes,
        'status': OrderItemStatus.pending,
        'course': entry.course.id,
        'removed_ingredients':
            entry.removedIngredients,
        'selected_extras': entry.selectedExtras
      };
      await _pb.collection('order_items').create(body: itemBody);
    }
  }

  @override
  Future<void> voidItem(
      {required String? orderItemId,
      required VoidReason reason,
      required String tableSessionId,
      required String menuItemId,
      required String menuItemName,
      required double amount,
      required int quantity,
      required bool refund,
      required String voidedBy,
      required OrderItemStatus statusWhenVoided,
      String? notes}) async {
    // Again, this should be a single backend transaction.
    final body = {
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
      'status_when_voided': statusWhenVoided,
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

  OrderItem _populateOrderItem(RecordModel r) {
    print("[PocketBaseRepository] Populating OrderItem from record ${r.id}");
    OrderItem item = OrderItem.fromJson(r.toJson());
    print(
        "[PocketBaseRepository] Base OrderItem: ${item.toString()} from JSON: ${r.toJson().toString()}");
    List<Extra> selectedExtras =
        (r.toJson()['expand']?['extras'] as List<dynamic>?)
                ?.map((e) => Extra.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
    Course course = Course.fromJson(
        r.toJson()['expand']?['course'] as Map<String, dynamic>? ?? {});
    List<Ingredient> removedIngredients =
        (r.toJson()['expand']?['removed_ingredients'] as List<dynamic>?)
                ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
    return item.copyWith(
        selectedExtras: selectedExtras,
        course: course,
        removedIngredients: removedIngredients);
  }
}

