import 'extra.dart';

class MenuItem {
  final int id;
  final String name;
  final double price;
  final String category;
  final bool popular;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> allergens;
  final List<Extra> availableExtras;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.popular,
    required this.imageUrl,
    required this.ingredients,
    required this.allergens,
    this.availableExtras = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      popular: json['popular'] as bool,
      imageUrl: json['imageUrl'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      allergens: List<String>.from(json['allergens'] as List),
      availableExtras: (json['availableExtras'] as List<dynamic>?)
              ?.map((e) => Extra.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'popular': popular,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'allergens': allergens,
      'availableExtras': availableExtras.map((e) => e.toJson()).toList(),
    };
  }
}