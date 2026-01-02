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

  MenuItem copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? collectionId,
    String? collectionName,
    String? name,
    String? description,
    double? price,
    Category? category,
    bool? isAvailable,
    List<Ingredient>? ingredients,
    List<Allergen>? allergens,
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
}
