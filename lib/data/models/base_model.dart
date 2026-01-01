abstract class BaseModel {
  final String id;
  final DateTime created;
  final DateTime updated;
  final String collectionId;
  final String collectionName;

  BaseModel({
    required this.id,
    required this.created,
    required this.updated,
    required this.collectionId,
    required this.collectionName,
  });

  /// Helper sicuro per convertire stringhe ISO o null in DateTime
  static DateTime parseDate(dynamic dateStr) {
    if (dateStr == null || dateStr == '') return DateTime.now();
    return DateTime.tryParse(dateStr.toString()) ?? DateTime.now();
  }
}