import '../base_model.dart';
import '../enums/payment_method.dart';

class Payment extends BaseModel {
  final String sessionId; // Relation
  final double amount;
  final PaymentMethod method; // TYPED
  final String? processedById; // Relation
  final List<String> coveredItemIds; // Relation (order_items)
  final String? transactionRef;
  final bool isDeposit;

  Payment({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.sessionId,
    required this.amount,
    required this.method,
    this.processedById,
    this.coveredItemIds = const [],
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
      coveredItemIds: (json['covered_items'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      transactionRef: json['transaction_ref'],
      isDeposit: json['is_deposit'] ?? false,
    );
  }
}