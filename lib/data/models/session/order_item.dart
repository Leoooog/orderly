import 'package:orderly/data/models/menu/extra.dart';
import 'package:orderly/data/models/menu/ingredient.dart';
import 'package:orderly/data/models/menu/menu_item.dart';

import '../base_model.dart';
import '../enums/order_item_status.dart';
import '../menu/course.dart';

class OrderItem extends BaseModel {
  final String orderId; // Relation
  final String menuItemId; // Relation

  final int quantity;
  final OrderItemStatus status; // TYPED
  final String menuItemName; // Snapshot of name
  final String? notes;
  final DateTime? firedAt; // Date
  final double paidQuantity;
  final double priceEach; // snapshot of price
  final bool requiresFiring; // snapshot derived from MenuItem

  //Da inizializzare nel repository
  final List<Extra> selectedExtras; // Relation
  final List<Ingredient> removedIngredients; // Relation
  final Course course;
  final MenuItem? menuItem;

  OrderItem({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.status,
    required this.menuItemName,
    required this.priceEach,
    required this.requiresFiring,
    this.selectedExtras = const [],
    this.removedIngredients = const [],
    required this.course,
    this.notes,
    this.firedAt,
    this.paidQuantity = 0.0,
    this.menuItem,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      orderId: json['order'] ?? '',
      menuItemId: json['menu_item'] ?? '',
      course: Course.empty(),
      requiresFiring: json['requires_firing'] ?? false,
      priceEach: (json['price_each'] as num? ?? 0).toDouble(),
      // Placeholder
      quantity: (json['quantity'] ?? 0),
      status: OrderItemStatus.fromString(json['status'] ?? ''),
      notes: json['notes'],
      firedAt: BaseModel.parseDateNullable(json['fired_at']),
      menuItemName: json['menu_item_name'] ?? '',
      paidQuantity: (json['paid_quantity'] as num? ?? 0).toDouble(),
    );
  }

  factory OrderItem.fromExpandedJson(Map<String, dynamic> json) {
    OrderItem item = OrderItem.fromJson(json);
    final expand = json['expand'] as Map<String, dynamic>? ?? {};

    Course? course = expand['course'] != null
        ? Course.fromJson(expand['course'] as Map<String, dynamic>)
        : null;

    List<Extra> selectedExtras = (expand['selected_extras'] as List<dynamic>?)
            ?.map((e) => Extra.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    List<Ingredient> removedIngredients =
        (expand['removed_ingredients'] as List<dynamic>?)
                ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
    MenuItem? menuItem = expand['menu_item'] != null
        ? MenuItem.fromExpandedJson(
            expand['menu_item'] as Map<String, dynamic>)
        : null;

    return item.copyWith(
      course: course,
      menuItem: menuItem,
      selectedExtras: selectedExtras,
      removedIngredients: removedIngredients,
    );
  }

  factory OrderItem.empty() {
    return OrderItem(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      collectionId: '',
      collectionName: '',
      menuItemId: '',
      menuItemName: '',
      orderId: '',
      requiresFiring: false,
      priceEach: 0.0,
      course: Course.empty(),
      menuItem: MenuItem.empty(),
      quantity: 0,
      status: OrderItemStatus.unknown,
    );
  }

  OrderItem copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? collectionId,
    String? collectionName,
    String? orderId,
    String? menuItemId,
    int? quantity,
    OrderItemStatus? status,
    String? menuItemName,
    double? priceEach,
    List<Extra>? selectedExtras,
    List<Ingredient>? removedIngredients,
    bool? requiresFiring,
    Course? course,
    String? notes,
    DateTime? firedAt,
    double? paidQuantity,
    MenuItem? menuItem,
  }) {
    return OrderItem(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      menuItemId: menuItemId ?? this.menuItemId,
      orderId: orderId ?? this.orderId,
      quantity: quantity ?? this.quantity,
      priceEach: priceEach ?? this.priceEach,
      status: status ?? this.status,
      menuItemName: menuItemName ?? this.menuItemName,
      requiresFiring: requiresFiring ?? this.requiresFiring,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      removedIngredients: removedIngredients ?? this.removedIngredients,
      course: course ?? this.course,
      notes: notes ?? this.notes,
      firedAt: firedAt ?? this.firedAt,
      paidQuantity: paidQuantity ?? this.paidQuantity,
      menuItem: menuItem ?? this.menuItem,
    );
  }

  @override
  String toString() {
    return 'OrderItem{orderId: $orderId, menuItemId: $menuItemId, quantity: $quantity, status: $status, menuItemName: $menuItemName, notes: $notes, firedAt: $firedAt, paidQuantity: $paidQuantity, priceEach: $priceEach, requiresFiring: $requiresFiring, selectedExtras: $selectedExtras, removedIngredients: $removedIngredients, course: $course, menuItem: $menuItem}';
  }
}
