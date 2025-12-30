import 'cart_item.dart';

enum TableStatus { free, seated, ordered, ready, eating }

class TableItem {
  final int id;
  final String name;
  TableStatus status; // 'occupied', 'free'
  int guests;
  List<CartItem> orders;

  TableItem({
    required this.id,
    required this.name,
    required this.status,
    this.guests = 0,
    this.orders = const [],
  });

  double get totalAmount => orders.fold(0.0, (sum, item) => sum + item.totalPrice);

  factory TableItem.fromJson(Map<String, dynamic> json) {
    return TableItem(
      id: json['id'] as int,
      name: json['name'] as String,
      status: TableStatus.values[json['status'] ?? 0],
      guests: json['guests'] as int,
      orders: (json['orders'] as List<dynamic>)
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.index, // AGGIUNTO .index
      'guests': guests,
      'orders': orders.map((e) => e.toJson()).toList(),
    };
  }

  TableItem copyWith({
    TableStatus? status,
    int? guests,
    List<CartItem>? orders,
  }) {
    return TableItem(
      id: id,
      name: name,
      status: status ?? this.status,
      guests: guests ?? this.guests,
      orders: orders ?? this.orders,
    );
  }
}