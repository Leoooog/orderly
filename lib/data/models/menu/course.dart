import '../base_model.dart';

class Course extends BaseModel {
  final String name;
  final int sortOrder;

  Course({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.name,
    this.sortOrder = 0,
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
    );
  }

  factory Course.empty() {
    return Course(
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
    return 'Course{name: $name, sortOrder: $sortOrder}';
  }
}