// Provider che espone i dati del ristorante (Mock per ora)
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/restaurant.dart';

final restaurantProvider = Provider<Restaurant>((ref) {
  return Restaurant(
    id: 'rambla_01',
    name: 'La Rambla',
    currencySymbol: '€',
    locale: 'it_IT',
    address: 'Via Roma 10, Milano',
    vatNumber: '12345678901',

    // CONFIGURAZIONE COPERTO
    coverCharge: 2.00, // 2 Euro a persona
    serviceFeePercent: 0.0,
  );
});