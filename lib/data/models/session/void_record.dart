import 'package:orderly/data/models/config/void_reason.dart';
import 'package:orderly/data/models/enums/order_item_status.dart';
import 'package:orderly/data/models/session/order_item.dart';

import '../base_model.dart';

class VoidRecord extends BaseModel {
  final String sessionId; // Relation
  final String menuItemId; // Relation
  final String menuItemName; // Snapshot of name
  final int quantity;
  final bool isRefunded;
  final String? notes;
  final OrderItemStatus statusWhenVoided;
  final double amount;

  // Da inizializzare nel repository
  final VoidReason reason; // Relation
  final OrderItem? orderItem;

  VoidRecord({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.reason,
    required this.quantity,
    required this.isRefunded,
    required this.statusWhenVoided,
    required this.amount,
    this.notes,
    this.orderItem,
    required this.sessionId,
    required this.menuItemId,
    required this.menuItemName,
  });

  factory VoidRecord.fromJson(Map<String, dynamic> json) {
    return VoidRecord(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      quantity: json['quantity'] ?? 0,
      isRefunded: json['is_refunded'] ?? false,
      notes: json['notes'],
      sessionId: json['session'] ?? '',
      menuItemId: json['menu_item'] ?? '',
      menuItemName: json['menu_item_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      statusWhenVoided:
          OrderItemStatus.fromString(json['status_when_voided'] ?? ''),
      // Relational fields are initialized empty and populated by the repository
      reason: VoidReason.empty(),
      orderItem: OrderItem.empty(),
    );
  }

  factory VoidRecord.empty() {
    return VoidRecord(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      collectionId: '',
      collectionName: '',
      quantity: 0,
      isRefunded: false,
      amount: 0.0,
      statusWhenVoided: OrderItemStatus.unknown,
      sessionId: '',
      menuItemId: '',
      menuItemName: '',
      reason: VoidReason.empty(),
    );
  }

  VoidRecord copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? collectionId,
    String? collectionName,
    String? sessionId,
    String? menuItemId,
    String? menuItemName,
    OrderItemStatus? statusWhenVoided,
    double? amount,
    int? quantity,
    bool? isRefunded,
    String? notes,
    OrderItem? orderItem,
    VoidReason? reason,
  }) {
    return VoidRecord(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      sessionId: sessionId ?? this.sessionId,
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      quantity: quantity ?? this.quantity,
      isRefunded: isRefunded ?? this.isRefunded,
      amount: amount ?? this.amount,
      statusWhenVoided: statusWhenVoided ?? this.statusWhenVoided,
      notes: notes ?? this.notes,
      orderItem: orderItem ?? this.orderItem,
      reason: reason ?? this.reason,
    );
  }
}
