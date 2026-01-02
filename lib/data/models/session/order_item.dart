import 'package:orderly/data/models/menu/extra.dart';
import 'package:orderly/data/models/menu/ingredient.dart';

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

  //Da inizializzare nel repository
  final List<Extra> selectedExtras; // Relation
  final List<Ingredient> removedIngredients; // Relation
  final Course course;

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
    this.selectedExtras = const [],
    this.removedIngredients = const [],
    required this.course,
    this.notes,
    this.firedAt,
    this.paidQuantity = 0.0,
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
      // Placeholder
      quantity: (json['quantity'] ?? 0).toDouble(),
      status: OrderItemStatus.fromString(json['status'] ?? ''),
      notes: json['notes'],
      firedAt: BaseModel.parseDateNullable(json['fired_at']),
      menuItemName: json['menu_item_name'] ?? '',
      paidQuantity: (json['paid_quantity'] ?? 0).toDouble(),
    );
  }

  factory OrderItem.empty() {
    return OrderItem(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      collectionId: '',
      collectionName: '',
      menuItemName: '',
      orderId: '',
      menuItemId: '',
      course: Course.empty(),
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
    List<Extra>? selectedExtras,
    List<Ingredient>? removedIngredients,
    Course? course,
    String? notes,
    DateTime? firedAt,
    double? paidQuantity,
  }) {
    return OrderItem(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      menuItemName: menuItemName ?? this.menuItemName,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      removedIngredients: removedIngredients ?? this.removedIngredients,
      course: course ?? this.course,
      notes: notes ?? this.notes,
      firedAt: firedAt ?? this.firedAt,
      paidQuantity: paidQuantity ?? this.paidQuantity,
    );
  }
}
