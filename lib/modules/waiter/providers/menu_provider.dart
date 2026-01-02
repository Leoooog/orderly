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

// For easier access to individual lists
final menuItemsProvider = Provider<List<MenuItem>>(
    (ref) => ref.watch(menuDataProvider).value?.menuItems ?? []);
final categoriesProvider = Provider<List<Category>>(
    (ref) => ref.watch(menuDataProvider).value?.categories ?? []);
final coursesProvider = Provider<List<Course>>(
    (ref) => ref.watch(menuDataProvider).value?.courses ?? []);
