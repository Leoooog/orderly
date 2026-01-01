import 'package:intl/intl.dart';

import '../../data/models/config/restaurant.dart';
import '../../data/models/session/order.dart';

extension SessionTotalCalculation on List<Order> {
  /// Calcola il totale di una sessione sommando i totali degli ordini.
  double get totalSessionAmount {
    if (isEmpty) return 0.0;
    return fold(0.0, (previousValue, order) => previousValue + order.totalAmount);
  }
}

extension CurrencyFormatting on double {
  /// Formatta un double in valuta usando le impostazioni del ristorante.
  /// Esempio: 10.5.toCurrency(restaurant) -> "€ 10,50" (se locale it_IT)
  String toCurrency(Restaurant? restaurant) {
    if (restaurant == null) {
      // Fallback di default
      return '€ ${toStringAsFixed(2)}';
    }

    final format = NumberFormat.currency(
      locale: restaurant.locale,
      symbol: restaurant.currencySymbol,
      decimalDigits: 2,
    );

    return format.format(this);
  }
}