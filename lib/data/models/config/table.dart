import '../base_model.dart';

class Table extends BaseModel {
  final String name;

  Table({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.name,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      name: json['name'] ?? '',
    );
  }

  factory Table.empty() {
    return Table(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      collectionId: '',
      collectionName: '',
      name: '',
    );
  }
}