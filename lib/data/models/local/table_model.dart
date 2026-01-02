import 'package:orderly/data/models/config/table.dart';
import 'package:orderly/data/models/enums/table_session_status.dart';
import 'package:orderly/data/models/enums/table_status.dart';
import 'package:orderly/data/models/session/table_session.dart';

import '../../../core/utils/extensions.dart';

/// A UI-specific model that combines data from multiple sources
/// to provide all necessary information for rendering a single table card.
class TableUiModel {
  /// The physical table object.
  final Table table;

  /// The current status of the physical table (e.g., free, occupied).
  final TableStatus status;

  /// The active session on the table, if one exists.
  /// This contains all order information.
  final TableSession? activeSession;

  /// The detailed status of the active session (e.g., seated, ordered, ready).
  /// This is null if the table is free.
  final TableSessionStatus? sessionStatus;

  const TableUiModel({
    required this.table,
    required this.status,
    this.activeSession,
    this.sessionStatus,
  });

  // --- Convenience Getters for the UI ---

  /// A unique identifier for the table card in lists.
  String get id => table.id;

  /// The display name of the table.
  String get name => table.name;

  /// The ID of the active session, if it exists.
  String? get sessionId => activeSession?.id;

  /// Returns true if the table has an active session.
  bool get isOccupied => status == TableStatus.occupied;

  /// The number of guests at the table.
  int get guestsCount => activeSession?.guestsCount ?? 0;

  /// The total bill amount for the active session.
  double get totalAmount => activeSession?.totalAmount ?? 0.0;

  factory TableUiModel.empty() {
    return TableUiModel(
      table: Table.empty(),
      status: TableStatus.free,
    );
  }
}