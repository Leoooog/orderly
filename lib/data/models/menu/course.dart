import '../base_model.dart';

class Course extends BaseModel {
  final String name;
  final int sortOrder;
  final bool requiresFiring;

  Course({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.name,
    this.sortOrder = 0,
    this.requiresFiring = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      name: json['name'] ?? '',
      sortOrder: (json['sort_order'] ?? 0).toInt(),
      requiresFiring: json['requires_firing'] ?? false,
    );
  }
}