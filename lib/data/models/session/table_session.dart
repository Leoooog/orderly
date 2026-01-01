import '../base_model.dart';
import '../enums/table_status.dart';

class TableSession extends BaseModel {
  final String tableId; // Relation
  final String? waiterId; // Relation
  final int guestsCount;
  final TableStatus status; // TYPED
  final DateTime openedAt; // Autodate (mapped to created)
  final DateTime? closedAt; // Date
  final String? notes;

  TableSession({
    required super.id,
    required super.created, // This will be openedAt
    required super.updated, // This will be updated_at
    required super.collectionId,
    required super.collectionName,
    required this.tableId,
    this.waiterId,
    this.guestsCount = 0,
    required this.status,
    required this.openedAt,
    this.closedAt,
    this.notes,
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
      status: TableStatus.fromString(json['status'] ?? ''),
      openedAt: openedAt,
      closedAt: json['closed_at'] != null && json['closed_at'] != ''
          ? DateTime.tryParse(json['closed_at'].toString())
          : null,
      notes: json['notes'],
    );
  }
}