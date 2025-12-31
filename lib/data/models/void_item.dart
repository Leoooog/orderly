import 'package:orderly/data/models/cart_item.dart';

class VoidItem {
  final String id;           // ID univoco dello storno
  final int tableId;         // Da che tavolo arriva
  final String tableName;    // Nome tavolo (per leggibilità)
  final String itemName;     // Nome del piatto
  final double unitPrice;    // Prezzo al momento dello storno
  final int quantity;        // Quanti ne sono stati tolti
  final ItemStatus statusWhenVoided; // Stato dell'item quando è stato stornato
  final String reason;       // "Errore", "Cliente andato via", ecc.
  final bool isRefunded; // Se è stato rimborsato o no
  final DateTime timestamp;  // Quando è successo

  VoidItem({
    required this.id,
    required this.tableId,
    required this.tableName,
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
    required this.statusWhenVoided,
    required this.reason,
    required this.isRefunded,
    required this.timestamp,
  });

  // Calcolo del valore perso
  double get totalVoidAmount => unitPrice * quantity;

  // --- SERIALIZZAZIONE (Per Hive/Backend) ---

  Map<String, dynamic> toJson() => {
    'id': id,
    'tableId': tableId,
    'tableName': tableName,
    'itemName': itemName,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'statusWhenVoided': statusWhenVoided.index,
    'reason': reason,
    'isRefunded': isRefunded,
    'timestamp': timestamp.toIso8601String(),
  };

  factory VoidItem.fromJson(Map<String, dynamic> json) {
    return VoidItem(
      id: json['id'],
      tableId: json['tableId'],
      tableName: json['tableName'],
      itemName: json['itemName'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'],
      statusWhenVoided: ItemStatus.values[json['statusWhenVoided']],
      reason: json['reason'],
      isRefunded: json['isRefunded'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}