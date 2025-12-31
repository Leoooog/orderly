import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/menu_item.dart';
import '../../../data/models/extra.dart';
import '../../../data/models/course.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {

  @override
  List<CartItem> build() {
    return [];
  }

  void addItem(MenuItem item, Course activeCourse) {
    final existingIndex = state.indexWhere((c) =>
    c.id == item.id &&
        c.notes.isEmpty &&
        c.course == activeCourse &&
        c.selectedExtras.isEmpty
    );

    if (existingIndex >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex) state[i].copyWith(qty: state[i].qty + 1) else state[i]
      ];
    } else {
      final newItem = CartItem(
        internalId: DateTime.now().millisecondsSinceEpoch,
        id: item.id,
        name: item.name,
        basePrice: item.price,
        course: activeCourse,
      );
      state = [...state, newItem];
    }
  }

  void incrementQty(int internalId) {
    state = [
      for (final item in state)
        if (item.internalId == internalId) item.copyWith(qty: item.qty + 1) else item
    ];
  }

  void decrementQty(int internalId) {
    state = [
      for (final item in state)
        if (item.internalId == internalId)
          if (item.qty > 1) item.copyWith(qty: item.qty - 1) else item.copyWith(qty: 0)
        else
          item
    ];
    state = state.where((item) => item.qty > 0).toList();
  }

  void removeItem(int internalId) {
    state = state.where((item) => item.internalId != internalId).toList();
  }

  void clear() {
    state = [];
  }

  // --- UPDATED: Split & Merge logic for Cart ---
  void updateItemConfig(CartItem originalItem, int qtyToModify, String newNote, Course newCourse, List<Extra> newExtras) {
    if (qtyToModify <= 0 || qtyToModify > originalItem.qty) return;

    if (originalItem.notes == newNote &&
        originalItem.course == newCourse &&
        _areExtrasEqual(originalItem.selectedExtras, newExtras)) {
      return;
    }

    final newState = List<CartItem>.from(state);
    final index = newState.indexWhere((c) => c.internalId == originalItem.internalId);
    if (index == -1) return;

    if (qtyToModify < originalItem.qty) {
      // Split
      newState[index] = originalItem.copyWith(qty: originalItem.qty - qtyToModify);
      final newItem = originalItem.copyWith(
          internalId: DateTime.now().millisecondsSinceEpoch,
          qty: qtyToModify,
          notes: newNote,
          course: newCourse,
          selectedExtras: newExtras
      );
      _mergeOrAdd(newState, newItem);
    } else {
      // Full Update
      newState.removeAt(index);
      final updatedItem = originalItem.copyWith(
          notes: newNote,
          course: newCourse,
          selectedExtras: newExtras
      );
      _mergeOrAdd(newState, updatedItem, insertAt: index);
    }
    state = newState;
  }

  void _mergeOrAdd(List<CartItem> items, CartItem newItem, {int? insertAt}) {
    final mergeTargetIndex = items.indexWhere((o) =>
    o.id == newItem.id &&
        o.notes == newItem.notes &&
        o.course == newItem.course &&
        _areExtrasEqual(o.selectedExtras, newItem.selectedExtras)
    );

    if (mergeTargetIndex != -1) {
      items[mergeTargetIndex] = items[mergeTargetIndex].copyWith(qty: items[mergeTargetIndex].qty + newItem.qty);
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
}