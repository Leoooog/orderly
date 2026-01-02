import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/menu/category.dart';
import 'package:orderly/data/models/menu/course.dart';
import 'package:orderly/data/models/menu/menu_item.dart';
import 'package:orderly/data/repositories/i_orderly_repository.dart';
import 'package:orderly/logic/providers/session_provider.dart';

/// Classe di stato per contenere tutti i dati relativi al menu.
class MenuData {
  final List<Category> categories;
  final List<MenuItem> menuItems;
  final List<Course> courses;

  const MenuData({
    this.categories = const [],
    this.menuItems = const [],
    this.courses = const [],
  });
}

/// Notifier che carica tutti i dati del menu dal repository.
final menuDataProvider =
    AsyncNotifierProvider<MenuDataNotifier, MenuData>(MenuDataNotifier.new);

class MenuDataNotifier extends AsyncNotifier<MenuData> {
  IOrderlyRepository? get _repo => ref.watch(sessionProvider).repository;

  @override
  Future<MenuData> build() async {
    final repo = _repo;
    if (repo == null) {
      // Se il repository non è disponibile (es. durante il login),
      // restituisce uno stato vuoto. La UI gestirà il caricamento.
      return const MenuData();
    }

    // Carica tutti i dati in parallelo per efficienza.
    final results = await Future.wait([
      repo.getCategories(),
      repo.getMenuItems(),
      repo.getCourses(),
    ]);

    return MenuData(
      categories: results[0] as List<Category>,
      menuItems: results[1] as List<MenuItem>,
      courses: results[2] as List<Course>,
    );
  }

  /// Permette di forzare l'aggiornamento dei dati del menu.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

// --- Provider Derivati ---
// Questi provider osservano il provider principale e ne estraggono solo
// una parte dello stato. Sono efficienti perché un widget che dipende
// solo dalle categorie non si ricostruirà se cambiano i piatti del menu.

/// Fornisce la lista delle categorie.
final categoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(menuDataProvider).value?.categories ?? [];
});

/// Fornisce la lista di tutti i piatti del menu.
final menuItemsProvider = Provider<List<MenuItem>>((ref) {
  return ref.watch(menuDataProvider).value?.menuItems ?? [];
});

/// Fornisce la lista delle portate (es. Antipasti, Primi).
final coursesProvider = Provider<List<Course>>((ref) {
  return ref.watch(menuDataProvider).value?.courses ?? [];
});

