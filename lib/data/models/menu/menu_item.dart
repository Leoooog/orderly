import '../base_model.dart';

class MenuItem extends BaseModel {
  final String name;
  final String? description;
  final double price;
  final String? categoryId; // Relation
  final bool isAvailable;
  final List<String> ingredientIds; // Relation
  final List<String> allergenIds; // Relation
  final List<String> allowedExtraIds; // Relation
  final String? producedById; // Relation (Department)
  final String? image; // File

  MenuItem({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.name,
    this.description,
    this.price = 0.0,
    this.categoryId,
    this.isAvailable = true,
    this.ingredientIds = const [],
    this.allergenIds = const [],
    this.allowedExtraIds = const [],
    this.producedById,
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
      categoryId: json['category'],
      isAvailable: json['is_available'] ?? true,
      ingredientIds: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      allergenIds: (json['allergens'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      allowedExtraIds: (json['allowed_extras'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      producedById: json['produced_by'],
      image: json['image'],
    );
  }
}