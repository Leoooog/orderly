import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:orderly/logic/providers/session_provider.dart';

import '../../data/models/local/cart_entry.dart';
import '../../data/models/session/order.dart';
import '../../data/models/session/order_item.dart';
import '../../data/models/session/table_session.dart';

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
  String toCurrency(WidgetRef ref) {
    final restaurant = ref.read(sessionProvider).currentRestaurant!;

    final format = NumberFormat.currency(
      locale: restaurant.locale,
      symbol: restaurant.currencySymbol,
    );
    return format.format(this);
  }
}

extension OrderItems on List<Order> {
  /// Ritorna tutti gli item di tutti gli ordini
  List<OrderItem> get allItems {
    if (isEmpty) return [];
    return expand((order) => order.items).toList();
  }
}

extension CartEntries on List<CartEntry> {
  double get totalAmount {
    if (isEmpty) return 0.0;
    return fold(0.0, (prev, entry) => prev + entry.totalItemPrice);
  }
}


extension OrderItemsDishQuantity on List<OrderItem> {
  /// Calcola il totale degli item
  int get totalDishQuantity {
    if (isEmpty) return 0;
    return fold(0, (prev, item) => prev + item.quantity);
  }
}

extension TableSessionUiHelpers on TableSession {
  /// Ritorna tutti gli item di tutti gli ordini della sessione
    List<OrderItem> get activeItems {
    if (orders.isEmpty) return [];
    return orders.expand((order) => order.items).toList();
  }

  /// Calcola il totale degli item
  double get totalAmount {
    if (orders.isEmpty) return 0.0;
    return orders.fold(0.0, (prev, order) => prev + order.totalAmount);
  }

}