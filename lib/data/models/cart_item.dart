import 'course.dart';
import 'extra.dart';

enum ItemStatus {
  pending, // Inserito, inviato in cucina, ma in attesa del "Via"
  fired,   // "Via" dato, in preparazione
  cooking, // Preparazione in corso
  ready,   // Pronto in cucina
  served; // Servito (opzionale per ora)

}

class CartItem {
  final int internalId;
  final int id;
  final String name;
  final double basePrice;
  int qty;
  String notes;
  Course course;
  List<Extra> selectedExtras;
  ItemStatus status; // NUOVO CAMPO

  CartItem({
    required this.internalId,
    required this.id,
    required this.name,
    required this.basePrice,
    this.qty = 1,
    this.notes = '',
    this.course = Course.entree,
    this.selectedExtras = const [],
    this.status = ItemStatus.pending, // Default: in attesa
  });

  double get unitPrice => basePrice + selectedExtras.fold(0.0, (sum, e) => sum + e.price);
  double get totalPrice => unitPrice * qty;

  CartItem copyWith({
    int? qty,
    String? notes,
    int? internalId,
    Course? course,
    List<Extra>? selectedExtras,
    ItemStatus? status, // NUOVO
  }) {
    return CartItem(
      internalId: internalId ?? this.internalId,
      id: id,
      name: name,
      basePrice: basePrice,
      qty: qty ?? this.qty,
      notes: notes ?? this.notes,
      course: course ?? this.course,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      status: status ?? this.status, // NUOVO
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      internalId: json['internalId'] as int,
      id: json['id'] as int,
      name: json['name'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      qty: json['qty'] as int,
      notes: json['notes'] as String,
      course: Course.values.firstWhere((c) => c.id == json['courseId'] as int),
      selectedExtras: (json['selectedExtras'] as List<dynamic>)
          .map((e) => Extra.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      status: ItemStatus.values.firstWhere((s) => s.index == json['status'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'internalId': internalId,
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'qty': qty,
      'notes': notes,
      'courseId': course.id,
      'selectedExtras': selectedExtras.map((e) => e.toJson()).toList(),
      'status': status.index,
    };
  }
}