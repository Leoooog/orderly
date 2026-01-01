import '../base_model.dart';

class Order extends BaseModel {
  final String sessionId; // Relation
  final String? waiterId; // Relation
  final double totalAmount;

  Order({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.sessionId,
    this.waiterId,
    this.totalAmount = 0.0,
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
}