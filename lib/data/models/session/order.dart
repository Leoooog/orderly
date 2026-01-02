import 'package:orderly/data/models/enums/order_item_status.dart';
import 'package:orderly/data/models/menu/menu_item.dart';
import 'package:orderly/data/models/session/order_item.dart';
import 'package:orderly/data/models/session/void_record.dart';

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
}