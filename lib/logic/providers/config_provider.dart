import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/config/restaurant.dart';
import 'package:orderly/logic/providers/session_provider.dart';

final restaurantProvider = FutureProvider<Restaurant>((ref) async {
  // 1. Ascoltiamo il sessionProvider.
  // Usiamo .future per attendere che l'inizializzazione (loading) sia completata.
  final sessionState = await ref.watch(sessionProvider.future);

  // 2. Poiché SessionNotifier carica getRestaurantInfo() nel suo build(),
  // il dato è già disponibile in memoria.
  if (sessionState.currentRestaurant == null) {
    throw Exception("Impossibile recuperare le info del ristorante: sessione non inizializzata.");
  }

  return sessionState.currentRestaurant!;
});