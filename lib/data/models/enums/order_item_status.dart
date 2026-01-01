enum OrderItemStatus {
  pending,
  fired,
  cooking,
  ready,
  served,
  unknown;

  static OrderItemStatus fromString(String value) {
    return OrderItemStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => OrderItemStatus.pending,
    );
  }

  String toJson() => name;
}