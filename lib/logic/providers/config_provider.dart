import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/config/restaurant.dart';
import 'package:orderly/logic/providers/session_provider.dart';

final restaurantProvider = FutureProvider<Restaurant>((ref) async {
  print("[ConfigProvider] fetching restaurant info...");
  final repo = ref.watch(sessionProvider).repository!;
  final restaurant = await repo.getRestaurantInfo();
  print("[ConfigProvider] fetched restaurant info for ${restaurant.name}");
  return restaurant;
});

