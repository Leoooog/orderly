import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/menu/category.dart';
import 'package:orderly/data/models/menu/course.dart';
import 'package:orderly/data/models/menu/menu_item.dart';
// Assicurati che repository_provider sia importato (creato nello step precedente)
import 'package:orderly/logic/providers/repository_provider.dart';

class MenuData {
  final List<MenuItem> menuItems;
  final List<Category> categories;
  final List<Course> courses;

  MenuData({
    required this.menuItems,
    required this.categories,
    required this.courses,
  });
}

final menuDataProvider = FutureProvider<MenuData>((ref) async {
  // 1. Ottieni il repository in modo asincrono.
  // Se il repository sta inizializzando, questo provider rimarrà in loading.
  final repo = (await ref.watch(repositoryProvider.future))!;

  // 2. Fetch parallelo per performance
  final results = await Future.wait([
    repo.getMenuItems(),
    repo.getCategories(),
    repo.getCourses(),
  ]);

  return MenuData(
    menuItems: results[0] as List<MenuItem>,
    categories: results[1] as List<Category>,
    courses: results[2] as List<Course>,
  );
});

final menuItemsProvider =
AsyncNotifierProvider<MenuItemNotifier, List<MenuItem>>(
    MenuItemNotifier.new);

class MenuItemNotifier extends AsyncNotifier<List<MenuItem>> {
  @override
  Future<List<MenuItem>> build() async {
    final data = await ref.watch(menuDataProvider.future);
    return data.menuItems;
  }

  Future<MenuItem> getMenuItemById(String id) async {
    // Usiamo future per assicurarci che i dati siano caricati
    final menuItems = await future;
    return menuItems.firstWhere((item) => item.id == id,
        orElse: () => MenuItem.empty());
  }
}

final categoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(menuDataProvider).value?.categories ?? [];
});

final coursesProvider = Provider<List<Course>>((ref) {
  return ref.watch(menuDataProvider).value?.courses ?? [];
});