import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/local/cart_entry.dart';
import '../../../data/models/menu/course.dart';
import '../../../data/models/menu/extra.dart';
import '../../../data/models/menu/ingredient.dart';
import '../../../data/models/menu/menu_item.dart';

final cartProvider =
    NotifierProvider<CartNotifier, List<CartEntry>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartEntry>> {
  @override
  List<CartEntry> build() {
    return [];
  }

  void addItem(MenuItem item, Course activeCourse) {
    // Cerca un articolo esistente che sia "semplice" (senza note, extra, ecc.)
    final existingIndex = state.indexWhere((c) =>
        c.item.id == item.id &&
        (c.notes == null || c.notes!.isEmpty) &&
        c.course.id == activeCourse.id &&
        c.selectedExtras.isEmpty &&
        c.removedIngredients.isEmpty);

    if (existingIndex >= 0) {
      // Se esiste, incrementa la quantità
      final existingItem = state[existingIndex];
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            existingItem.copyWith(quantity: existingItem.quantity + 1)
          else
            state[i]
      ];
    } else {
      // Altrimenti, crea un nuovo CartEntry
      final newItem = CartEntry(
        internalId: DateTime.now().millisecondsSinceEpoch,
        item: item,
        quantity: 1,
        course: activeCourse,
      );
      state = [...state, newItem];
    }
  }

  void incrementQty(int internalId) {
    state = [
      for (final entry in state)
        if (entry.internalId == internalId)
          entry.copyWith(quantity: entry.quantity + 1)
        else
          entry
    ];
  }

  void decrementQty(int internalId) {
    final target = state.firstWhere((e) => e.internalId == internalId);
    if (target.quantity > 1) {
      state = [
        for (final entry in state)
          if (entry.internalId == internalId)
            entry.copyWith(quantity: entry.quantity - 1)
          else
            entry
      ];
    } else {
      // Se la quantità è 1, rimuovi l'articolo
      removeItem(internalId);
    }
  }

  void removeItem(int internalId) {
    state = state.where((item) => item.internalId != internalId).toList();
  }

  void clear() {
    state = [];
  }

  // --- Logica di modifica e unione per il carrello ---
  void updateItemConfig(CartEntry originalItem, int qtyToModify, String newNote,
      Course newCourse, List<Extra> newExtras, List<Ingredient> removedIngredients) {
    if (qtyToModify <= 0 || qtyToModify > originalItem.quantity) return;

    // Se non è cambiato nulla, non fare niente
    if (originalItem.notes == newNote &&
        originalItem.course.id == newCourse.id &&
        _areExtrasEqual(originalItem.selectedExtras, newExtras) &&
        _areIngredientsEqual(originalItem.removedIngredients, removedIngredients)) {
      return;
    }

    final newState = List<CartEntry>.from(state);
    final index =
        newState.indexWhere((c) => c.internalId == originalItem.internalId);
    if (index == -1) return;

    if (qtyToModify < originalItem.quantity) {
      // SPLIT: Modifica solo una parte della quantità
      newState[index] =
          originalItem.copyWith(quantity: originalItem.quantity - qtyToModify);
      final newItem = originalItem.copyWith(
        internalId: DateTime.now().millisecondsSinceEpoch,
        quantity: qtyToModify,
        notes: newNote,
        course: newCourse,
        selectedExtras: newExtras,
        removedIngredients: removedIngredients,
      );
      _mergeOrAdd(newState, newItem);
    } else {
      // UPDATE COMPLETO: Modifica l'intero blocco
      newState.removeAt(index);
      final updatedItem = originalItem.copyWith(
        notes: newNote,
        course: newCourse,
        selectedExtras: newExtras,
        removedIngredients: removedIngredients,
      );
      _mergeOrAdd(newState, updatedItem, insertAt: index);
    }
    state = newState;
  }

  void _mergeOrAdd(List<CartEntry> items, CartEntry newItem, {int? insertAt}) {
    final mergeTargetIndex = items.indexWhere((o) =>
        o.item.id == newItem.item.id &&
        o.notes == newItem.notes &&
        o.course.id == newItem.course.id &&
        _areExtrasEqual(o.selectedExtras, newItem.selectedExtras) &&
        _areIngredientsEqual(o.removedIngredients, newItem.removedIngredients));

    if (mergeTargetIndex != -1) {
      final target = items[mergeTargetIndex];
      items[mergeTargetIndex] =
          target.copyWith(quantity: target.quantity + newItem.quantity);
    } else {
      if (insertAt != null && insertAt <= items.length) {
        items.insert(insertAt, newItem);
      } else {
        items.add(newItem);
      }
    }
  }

  bool _areExtrasEqual(List<Extra> a, List<Extra> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.id).toSet();
    final bIds = b.map((e) => e.id).toSet();
    return aIds.containsAll(bIds);
  }

  bool _areIngredientsEqual(List<Ingredient> a, List<Ingredient> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.id).toSet();
    final bIds = b.map((e) => e.id).toSet();
    return aIds.containsAll(bIds);
  }
}