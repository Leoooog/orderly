import '../menu/course.dart';
import '../menu/extra.dart';
import '../menu/ingredient.dart';
import '../menu/menu_item.dart';

class CartEntry {
  final MenuItem item;
  final int quantity;
  final Course course;
  final List<Extra> selectedExtras;
  final List<Ingredient> removedIngredients;
  final String? notes;

  CartEntry({
    required this.item,
    required this.quantity,
    required this.course,
    this.selectedExtras = const [],
    this.removedIngredients = const [],
    this.notes,
  });
}
