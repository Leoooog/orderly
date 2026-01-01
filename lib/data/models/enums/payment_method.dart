enum PaymentMethod {
  cash,
  card,
  unknown;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
          (e) => e.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }

  String toJson() => name;
}