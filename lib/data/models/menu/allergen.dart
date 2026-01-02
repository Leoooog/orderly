import '../base_model.dart';

class Allergen extends BaseModel {
  final String name;
  final String code;

  Allergen({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.name,
    required this.code,
  });

  factory Allergen.fromJson(Map<String, dynamic> json) {
    return Allergen(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      name: json['name'] ?? '', code: '',
    );
  }

  @override
  String toString() {
    return 'Allergen{name: $name, code: $code}';
  }
}