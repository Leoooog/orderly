import '../base_model.dart';

class Category extends BaseModel {
  final String name;
  final int sortOrder;

  Category({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.name,
    this.sortOrder = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      name: json['name'] ?? '',
      sortOrder: (json['sort_order'] ?? 0).toInt(),
    );
  }

  factory Category.empty() {
    return Category(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      collectionId: '',
      collectionName: '',
      name: '',
      sortOrder: 0,
    );
  }

  @override
  String toString() {
    return 'Category{name: $name, sortOrder: $sortOrder}';
  }
}