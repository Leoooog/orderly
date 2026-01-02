import '../menu/course.dart';
import '../menu/extra.dart';
import '../menu/ingredient.dart';
import '../menu/menu_item.dart';

class CartEntry {
  final int internalId; // Unique ID for the cart instance
  final MenuItem item;
  final int quantity;
  final Course course;
  final List<Extra> selectedExtras;
  final List<Ingredient> removedIngredients;
  final String? notes;

  CartEntry({
    required this.internalId,
    required this.item,
    required this.quantity,
    required this.course,
    this.selectedExtras = const [],
    this.removedIngredients = const [],
    this.notes,
  });

  double get totalItemPrice {
    final extrasPrice =
        selectedExtras.fold(0.0, (sum, extra) => sum + extra.price);
    return (item.price + extrasPrice) * quantity;
  }

  CartEntry copyWith({
    int? internalId,
    MenuItem? item,
    int? quantity,
    Course? course,
    List<Extra>? selectedExtras,
    List<Ingredient>? removedIngredients,
    String? notes,
  }) {
    return CartEntry(
      internalId: internalId ?? this.internalId,
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      course: course ?? this.course,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      removedIngredients: removedIngredients ?? this.removedIngredients,
      notes: notes ?? this.notes,
    );
  }
}
