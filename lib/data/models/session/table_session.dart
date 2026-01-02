import 'package:orderly/data/models/session/order.dart';
import 'package:orderly/data/models/session/payment.dart';

import '../base_model.dart';
import '../enums/table_status.dart';
import 'void_record.dart';

class TableSession extends BaseModel {
  final String tableId; // Relation
  final String waiterId; // Relation
  final int guestsCount;
  final TableSessionStatus status; // TYPED
  final DateTime openedAt; // Autodate (mapped to created)
  final DateTime? closedAt; // Date
  final String? notes;

  // da inizializzare nel repository
  final List<Order> orders;
  final List<Payment> payments;
  final List<VoidRecord> voids;



  TableSession({
    required super.id,
    required super.created, // This will be openedAt
    required super.updated, // This will be updated_at
    required super.collectionId,
    required super.collectionName,
    required this.tableId,
    required this.waiterId,
    required this.guestsCount,
    required this.status,
    required this.openedAt,
    this.closedAt,
    this.notes,
    this.orders = const [],
    this.payments = const [],
    this.voids = const [],
  });

  factory TableSession.fromJson(Map<String, dynamic> json) {
    // Handling specific date fields for TableSession
    // 'opened_at' is essentially creation time in this schema
    final openedAt = BaseModel.parseDate(json['opened_at']);
    final updatedAt = BaseModel.parseDate(json['updated_at']);

    return TableSession(
      id: json['id'] ?? '',
      created: openedAt,
      updated: updatedAt,
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      tableId: json['table'] ?? '',
      waiterId: json['waiter'],
      guestsCount: (json['guests_count'] ?? 0).toInt(),
      status: TableSessionStatus.fromString(json['status'] ?? ''),
      openedAt: openedAt,
      closedAt: BaseModel.parseDate(json['closed_at']),
      notes: json['notes'],
    );
  }

  factory TableSession.empty() {
    return TableSession(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      collectionId: '',
      collectionName: '',
      tableId: '',
      waiterId: '',
      guestsCount: 0,
      status: TableSessionStatus.unknown,
      openedAt: DateTime.now(),
    );
  }

  bool get isEmpty => id.isEmpty;

  TableSession copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? collectionId,
    String? collectionName,
    String? tableId,
    String? waiterId,
    int? guestsCount,
    TableSessionStatus? status,
    DateTime? openedAt,
    DateTime? closedAt,
    String? notes,
    List<Order>? orders,
    List<Payment>? payments,
    List<VoidRecord>? voids,
  }) {
    return TableSession(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      tableId: tableId ?? this.tableId,
      waiterId: waiterId ?? this.waiterId,
      guestsCount: guestsCount ?? this.guestsCount,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      notes: notes ?? this.notes,
      orders: orders ?? this.orders,
      payments: payments ?? this.payments,
      voids: voids ?? this.voids,
    );
  }

}