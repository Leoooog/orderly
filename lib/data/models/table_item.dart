import 'cart_item.dart';

class TableItem {
  final int id;
  final String name;
  String status; // 'occupied', 'free'
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
}