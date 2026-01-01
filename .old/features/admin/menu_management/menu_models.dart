class Category {
  final int id;
  final String name;
  List<Dish> dishes = [];

  Category({required this.id, required this.name, this.dishes = const []});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Dish {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;

  Dish({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
    };
  }
}