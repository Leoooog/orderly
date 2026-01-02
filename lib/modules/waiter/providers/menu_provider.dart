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
  print("[MenuProvider] fetching menu data...");
  final repo = ref.watch(sessionProvider).repository!;
  final menuItems = await repo.getMenuItems();
  final categories = await repo.getCategories();
  final courses = await repo.getCourses();

  print(
      "[MenuProvider] fetched ${menuItems.length} items, ${categories.length} categories, ${courses.length} courses");
  return MenuData(
    menuItems: menuItems,
    categories: categories,
    courses: courses,
  );
});

// For easier access to individual lists
final menuItemsProvider = Provider<List<MenuItem>>((ref) {
  final menuData = ref.watch(menuDataProvider).value;
  print("[MenuProvider] menuItemsProvider updated with ${menuData?.menuItems.length ?? 0} items");
  return menuData?.menuItems ?? [];
});
final categoriesProvider = Provider<List<Category>>((ref) {
  final menuData = ref.watch(menuDataProvider).value;
  print("[MenuProvider] categoriesProvider updated with ${menuData?.categories.length ?? 0} categories");
  return menuData?.categories ?? [];
});
final coursesProvider = Provider<List<Course>>((ref) {
  final menuData = ref.watch(menuDataProvider).value;
  print("[MenuProvider] coursesProvider updated with ${menuData?.courses.length ?? 0} courses");
  return menuData?.courses ?? [];
});
