class RestaurantTable {
  final int id; // bigint → int in Dart
  final String name;
  final String status;
  final int? seats;

  RestaurantTable({
    required this.id,
    required this.name,
    required this.status,
    this.seats,
  });

  factory RestaurantTable.fromMap(Map<String, dynamic> map) {
    return RestaurantTable(
      id: map['id'],
      name: map['name'],
      status: map['status'],
      seats: map['seats'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'seats': seats,
    };
  }
}