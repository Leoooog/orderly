class VoidItem {
  final String id;           // ID univoco dello storno
  final int tableId;         // Da che tavolo arriva
  final String tableName;    // Nome tavolo (per leggibilità)
  final String itemName;     // Nome del piatto
  final double unitPrice;    // Prezzo al momento dello storno
  final int quantity;        // Quanti ne sono stati tolti
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
    'reason': reason,
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
      reason: json['reason'],
      isRefunded: json['isRefunded'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}