import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/menu/category.dart';
import 'package:orderly/data/models/menu/course.dart';
import 'package:orderly/data/models/menu/menu_item.dart';
import 'package:orderly/logic/providers/session_provider.dart';

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
  final repo = ref.watch(sessionProvider).repository!;
  final menuItems = await repo.getMenuItems();
  final categories = await repo.getCategories();
  final courses = await repo.getCourses();

  return MenuData(
    menuItems: menuItems,
    categories: categories,
    courses: courses,
  );
});

final menuItemsProvider =
    AsyncNotifierProvider<MenuItemNotifier, List<MenuItem>>(
        MenuItemNotifier.new);

class MenuItemNotifier extends AsyncNotifier<List<MenuItem>> {
  @override
  Future<List<MenuItem>> build() async {
    return ref.watch(menuDataProvider).value?.menuItems ?? [];
  }

  Future<MenuItem> getMenuItemById(String id) async {
    final menuItems = await build();
    return menuItems.firstWhere((item) => item.id == id,
        orElse: () => MenuItem.empty());
  }
// For easier access to individual lists
}

final categoriesProvider = Provider<List<Category>>(
    (ref) => ref.watch(menuDataProvider).value?.categories ?? []);

final coursesProvider = Provider<List<Course>>(
    (ref) => ref.watch(menuDataProvider).value?.courses ?? []);
