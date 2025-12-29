import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category.dart';
import '../../../data/models/menu_item.dart';
import '../../../data/mock_data.dart'; // Fonte dati (Mock o Repository futuro)

// Provider semplice per le categorie (Read-only)
final categoriesProvider = Provider<List<Category>>((ref) {
  return categories;
});

// Provider semplice per i prodotti del menu (Read-only)
final menuProvider = Provider<List<MenuItem>>((ref) {
  return menuItems;
});