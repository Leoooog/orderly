class Extra {
  final String id;
  final String name;
  final double price;
  Extra(this.id, this.name, this.price);

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      json['id'] as String,
      json['name'] as String,
      (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}