import '../../admin/menu_management/menu_models.dart';

class Order {
  final int id;
  final String restaurantId;
  final int tableId;
  final String tableName;
  final String staffName;
  final String staffId;
  final DateTime createdAt;
  final String status;
  final String orderNotes;
  final List<OrderItemDraft> items;

  Order({
    required this.id,
    required this.restaurantId,
    required this.tableId,
    required this.tableName,
    required this.staffName,
    required this.staffId,
    required this.createdAt,
    required this.status,
    this.orderNotes = '',
    this.items = const [],
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      restaurantId: map['restaurant_id'],
      tableId: map['table_id'],
      tableName: map['table_name'],
      staffName: map['staff_name'],
      staffId: map['staff_id'],
      createdAt: DateTime.parse(map['created_at']),
      status: map['status'],
      orderNotes: map['order_notes'] ?? '',
      items: (map['order_items'] as List<dynamic>?)
              ?.map((item) => OrderItemDraft.fromMap(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'table_id': tableId,
      'staff_name': staffName,
      'staff_id': staffId,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'order_notes': orderNotes,
      'order_items': items.map((item) => item.toMap()).toList(),
    };
  }
}

class OrderItemDraft {
  final Dish dish;
  int quantity;
  String? notes;

  OrderItemDraft({
    required this.dish,
    this.quantity = 1,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'dish_id': dish.id,
      'dish': dish.toMap(),
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory OrderItemDraft.fromMap(Map<String, dynamic> map) {
    return OrderItemDraft(
      dish: Dish.fromMap(map['dishes']),
      quantity: map['quantity'],
      notes: map['notes'],
    );
  }
}
