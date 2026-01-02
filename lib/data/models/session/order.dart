import 'package:orderly/data/models/session/order_item.dart';

import '../base_model.dart';

class Order extends BaseModel {

  final String sessionId; // Relation
  final String waiterId; // Relation
  final double totalAmount;

  final List<OrderItem> items ;

  Order({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.sessionId,
    required this.waiterId,
    this.totalAmount = 0.0,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      sessionId: json['session'] ?? '',
      waiterId: json['waiter'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
    );
  }
  factory Order.empty() {
    return Order(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      collectionId: '',
      collectionName: '',
      sessionId: '',
      waiterId: '',
      totalAmount: 0.0,
    );
  }

  Order copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? collectionId,
    String? collectionName,
    String? sessionId,
    String? waiterId,
    double? totalAmount,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      sessionId: sessionId ?? this.sessionId,
      waiterId: waiterId ?? this.waiterId,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
    );
  }

  @override
  String toString() {
    return 'Order{sessionId: $sessionId, waiterId: $waiterId, totalAmount: $totalAmount, items: $items}';
  }
}