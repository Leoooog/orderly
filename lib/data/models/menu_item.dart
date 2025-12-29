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
}