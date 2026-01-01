import '../base_model.dart';

class Restaurant extends BaseModel {

  final String name;
  final String address;
  final String vatNumber;
  final String locale; // String 'it_IT', 'en_EN'
  final String currencySymbol; // String '€', '$'
  final double coverCharge;
  final double serviceFeePercent;

  Restaurant({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.name,
    required this.address,
    required this.vatNumber,
    required this.locale,
    required this.currencySymbol,
    this.coverCharge = 0.0,
    this.serviceFeePercent = 0.0,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      vatNumber: json['vat_number'] ?? '',
      locale: json['locale'] ?? 'it_IT',
      currencySymbol: json['currency_symbol'] ?? '€',
      coverCharge: (json['coverCharge'] ?? 0).toDouble(),
      serviceFeePercent: (json['serviceFeePercent'] ?? 0).toDouble(),
    );
  }
}