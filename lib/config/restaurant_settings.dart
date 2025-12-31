import 'package:intl/intl.dart';

class RestaurantConfig {
  static const String currencySymbol = '€';
  static const String locale = 'it_IT';
}

extension CurrencyFormatter on double {
  String toCurrency() {
    final format = NumberFormat.currency(
      locale: RestaurantConfig.locale,
      symbol: RestaurantConfig.currencySymbol,
      decimalDigits: 2, // Forza sempre 2 decimali
    );
    return format.format(this);
  }
}