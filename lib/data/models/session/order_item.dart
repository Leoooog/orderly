import '../base_model.dart';
import '../enums/order_item_status.dart';

class OrderItem extends BaseModel {
  final String orderId; // Relation
  final String menuItemId; // Relation
  final String courseId; // Relation
  final String departmentId; // Relation
  final double quantity;
  final OrderItemStatus status; // TYPED
  final List<String> selectedExtraIds; // Relation
  final List<String> removedIngredientIds; // Relation
  final String? notes;
  final DateTime? firedAt; // Date
  final double paidQuantity;

  OrderItem({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.orderId,
    required this.menuItemId,
    required this.courseId,
    required this.departmentId,
    required this.quantity,
    required this.status,
    this.selectedExtraIds = const [],
    this.removedIngredientIds = const [],
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
      courseId: json['course'] ?? '',
      departmentId: json['department'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      status: OrderItemStatus.fromString(json['status'] ?? ''),
      selectedExtraIds: (json['selected_extras'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      removedIngredientIds: (json['removed_ingredients'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      notes: json['notes'],
      firedAt: json['fired_at'] != null && json['fired_at'] != ''
          ? DateTime.tryParse(json['fired_at'].toString())
          : null,
      paidQuantity: (json['paid_quantity'] ?? 0).toDouble(),
    );
  }
}