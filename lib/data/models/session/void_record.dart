import '../base_model.dart';
import '../enums/order_item_status.dart';

class VoidRecord extends BaseModel {
  final String sessionId; // Relation
  final String menuItemName; // Snapshot of name
  final int quantity;
  final double amount;
  final bool isRefunded;
  final OrderItemStatus statusWhenVoided; // Reusing OrderItemStatus
  final String? notes;
  final String? voidedById; // Relation (User)
  final String? reasonId; // Relation (VoidReason)

  VoidRecord({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.sessionId,
    required this.menuItemName,
    required this.quantity,
    required this.amount,
    this.isRefunded = false,
    required this.statusWhenVoided,
    this.notes,
    this.voidedById,
    this.reasonId,
  });

  factory VoidRecord.fromJson(Map<String, dynamic> json) {
    return VoidRecord(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      sessionId: json['session'] ?? '',
      menuItemName: json['menu_item_name'] ?? '',
      quantity: (json['quantity'] ?? 0).toInt(),
      amount: (json['amount'] ?? 0).toDouble(),
      isRefunded: json['is_refunded'] ?? false,
      statusWhenVoided: OrderItemStatus.fromString(json['status_when_voided'] ?? ''),
      notes: json['notes'],
      voidedById: json['voided_by'],
      reasonId: json['reason'],
    );
  }
}