import 'course.dart';
import 'extra.dart';

class CartItem {
  final int internalId;
  final int id;
  final String name;
  final double basePrice;
  int qty;
  String notes;
  Course course;
  List<Extra> selectedExtras;

  CartItem({
    required this.internalId,
    required this.id,
    required this.name,
    required this.basePrice,
    this.qty = 1,
    this.notes = '',
    this.course = Course.entree,
    this.selectedExtras = const [],
  });

  double get unitPrice => basePrice + selectedExtras.fold(0.0, (sum, e) => sum + e.price);
  double get totalPrice => unitPrice * qty;

  CartItem copyWith({int? qty, String? notes, int? internalId, Course? course, List<Extra>? selectedExtras}) {
    return CartItem(
      internalId: internalId ?? this.internalId,
      id: id,
      name: name,
      basePrice: basePrice,
      qty: qty ?? this.qty,
      notes: notes ?? this.notes,
      course: course ?? this.course,
      selectedExtras: selectedExtras ?? this.selectedExtras,
    );
  }
}