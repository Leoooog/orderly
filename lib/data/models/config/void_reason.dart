import '../base_model.dart';

class VoidReason extends BaseModel {
  final String name;

  VoidReason({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.name,
  });

  factory VoidReason.fromJson(Map<String, dynamic> json) {
    return VoidReason(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      name: json['name'] ?? '',
    );
  }

  factory VoidReason.empty() {
    return VoidReason(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      collectionId: '',
      collectionName: '',
      name: '',
    );
  }

  @override
  String toString() {
    return 'VoidReason(id: $id, reason: $name)';
  }
}