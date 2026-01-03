import 'package:orderly/data/models/config/department.dart';
import 'package:orderly/data/models/menu/allergen.dart';
import 'package:orderly/data/models/menu/extra.dart';
import 'package:orderly/data/models/menu/ingredient.dart';

import '../base_model.dart';
import 'category.dart';

class MenuItem extends BaseModel {
  final String name;
  final String? description;
  final double price;
  final bool isAvailable;
  final String? image; // File

  // Da inizializzare nel repository
  final List<Ingredient> ingredients; // Relation
  final Category category;
  final List<Allergen> allergens; // Relation
  final List<Extra> allowedExtras; // Relation
  final List<Department> producedBy; // Relation (Department)

  MenuItem({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.name,
    this.description,
    this.price = 0.0,
    required this.category,
    this.isAvailable = true,
    this.ingredients = const [],
    this.allergens = const [],
    this.allowedExtras = const [],
    this.producedBy = const [],
    this.image,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      isAvailable: json['is_available'] ?? true,
      image: json['image'],
      category: Category.empty(), // Placeholder
      // Note: Relations should be initialized in the repository
    );
  }

  bool get requiresFiring => producedBy.isNotEmpty;

  factory MenuItem.fromExpandedJson(Map<String, dynamic> json) {
    MenuItem item = MenuItem.fromJson(json);
    final expand = json['expand'] as Map<String, dynamic>? ?? {};

    Category? category = expand['category'] != null
        ? Category.fromJson(expand['category'] as Map<String, dynamic>)
        : null;

    List<Allergen> allergens = (expand['allergens'] as List<dynamic>?)
            ?.map((e) => Allergen.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    List<Ingredient> ingredients = (expand['ingredients'] as List<dynamic>?)
            ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    List<Extra> extras = (expand['allowed_extras'] as List<dynamic>?)
            ?.map((e) => Extra.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    List<Department> producedBy = (expand['produced_by'] as List<dynamic>?)
            ?.map((e) => Department.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return item.copyWith(
        category: category,
        allergens: allergens,
        ingredients: ingredients,
        allowedExtras: extras,
        producedBy: producedBy);
  }

  factory MenuItem.empty() {
    return MenuItem(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      collectionId: '',
      collectionName: '',
      name: '',
      description: null,
      price: 0.0,
      category: Category.empty(),
      isAvailable: true,
      ingredients: [],
      allergens: [],
      allowedExtras: [],
      producedBy: [],
      image: null,
    );
  }

  bool get isEmpty => id.isEmpty;

  MenuItem copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? collectionId,
    String? collectionName,
    String? name,
    bool? isAvailable,
    String? description,
    double? price,
    Category? category,
    List<Allergen>? allergens,
    List<Ingredient>? ingredients,
    List<Extra>? allowedExtras,
    List<Department>? producedBy,
    String? image,
  }) {
    return MenuItem(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      allowedExtras: allowedExtras ?? this.allowedExtras,
      producedBy: producedBy ?? this.producedBy,
      image: image ?? this.image,
    );
  }

  @override
  String toString() {
    return 'MenuItem{name: $name, description: $description, price: $price, isAvailable: $isAvailable, image: $image, ingredients: $ingredients, category: $category, allergens: $allergens, allowedExtras: $allowedExtras, producedBy: $producedBy}';
  }
}
