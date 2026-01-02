import 'package:orderly/data/models/session/order_item.dart';

import '../base_model.dart';
import '../enums/payment_method.dart';

class Payment extends BaseModel {
  final String sessionId; // Relation
  final double amount;
  final PaymentMethod method; // TYPED
  final String processedById; // Relation

  final String? transactionRef;
  final bool isDeposit;

  final List<OrderItem>? coveredItems; // Relation (order_items)

  Payment({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.sessionId,
    required this.amount,
    required this.method,
    required this.processedById,
    this.coveredItems = const [],
    this.transactionRef,
    this.isDeposit = false,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      sessionId: json['session'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      method: PaymentMethod.fromString(json['method'] ?? ''),
      processedById: json['processed_by'],
      transactionRef: json['transaction_ref'],
      isDeposit: json['is_deposit'] ?? false,
    );
  }

  factory Payment.empty() {
    return Payment(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      collectionId: '',
      collectionName: '',
      sessionId: '',
      amount: 0.0,
      method: PaymentMethod.unknown,
      processedById: '',
    );
  }

  Payment copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? collectionId,
    String? collectionName,
    String? sessionId,
    double? amount,
    PaymentMethod? method,
    String? processedById,
    List<OrderItem>? coveredItems,
    String? transactionRef,
    bool? isDeposit,
  }) {
    return Payment(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      sessionId: sessionId ?? this.sessionId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      processedById: processedById ?? this.processedById,
      coveredItems: coveredItems ?? this.coveredItems,
      transactionRef: transactionRef ?? this.transactionRef,
      isDeposit: isDeposit ?? this.isDeposit,
    );
  }

  @override
  String toString() {
    return 'Payment{sessionId: $sessionId, amount: $amount, method: $method, processedById: $processedById, transactionRef: $transactionRef, isDeposit: $isDeposit, coveredItems: $coveredItems}';
  }
}