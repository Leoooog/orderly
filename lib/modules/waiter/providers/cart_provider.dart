import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/menu_item.dart';
import '../../../data/models/extra.dart';
import '../../../data/models/course.dart'; // Assicurati di avere questo file o definiscilo in models.dart

// Provider globale per il carrello
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {

  @override
  List<CartItem> build() {
    return []; // Stato iniziale vuoto
  }

  // --- AZIONI ---

  // Aggiunge un prodotto. Se esiste già identico (stesso corso, no note/extra), incrementa la quantità.
  void addItem(MenuItem item, Course activeCourse) {
    // Cerchiamo un item "compatibile" per il merge
    final existingIndex = state.indexWhere((c) =>
    c.id == item.id &&
        c.notes.isEmpty &&
        c.course == activeCourse &&
        c.selectedExtras.isEmpty
    );

    if (existingIndex >= 0) {
      // Trovato: incrementiamo la quantità
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            state[i].copyWith(qty: state[i].qty + 1)
          else
            state[i]
      ];
    } else {
      // Non trovato: aggiungiamo nuovo item
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

  // Incrementa quantità
  void incrementQty(int internalId) {
    state = [
      for (final item in state)
        if (item.internalId == internalId)
          item.copyWith(qty: item.qty + 1)
        else
          item
    ];
  }

  // Decrementa quantità (rimuove se arriva a 0)
  void decrementQty(int internalId) {
    state = [
      for (final item in state)
        if (item.internalId == internalId)
          if (item.qty > 1)
            item.copyWith(qty: item.qty - 1)
          else
          // Non facciamo nulla qui, lo filtriamo dopo per pulizia
            item.copyWith(qty: 0)
        else
          item
    ];
    // Pulizia: Rimuovi item con qty 0
    state = state.where((item) => item.qty > 0).toList();
  }

  // Rimuove completamente un item
  void removeItem(int internalId) {
    state = state.where((item) => item.internalId != internalId).toList();
  }

  // Svuota il carrello (dopo l'invio)
  void clear() {
    state = [];
  }

  // Logica avanzata per modificare un item esistente (Note, Corso, Extra)
  // Gestisce lo "Split" (se qty > 1) e il "Merge" (se la modifica rende l'item uguale a un altro)
  void updateItemConfig(CartItem originalItem, String newNote, Course newCourse, List<Extra> newExtras) {
    // 1. Se non è cambiato nulla, esci
    if (originalItem.notes == newNote &&
        originalItem.course == newCourse &&
        _areExtrasEqual(originalItem.selectedExtras, newExtras)) {
      return;
    }

    // Creiamo una copia modificabile della lista attuale
    List<CartItem> newState = List.from(state);

    // Indice dell'item che stiamo modificando
    final index = newState.indexWhere((c) => c.internalId == originalItem.internalId);
    if (index == -1) return; // Sicurezza

    // 2. Riduciamo/Rimuoviamo l'originale
    if (originalItem.qty > 1) {
      // Se era un gruppo, riduciamo di 1 (lo "splittiamo")
      newState[index] = originalItem.copyWith(qty: originalItem.qty - 1);
    } else {
      // Se era singolo, lo rimuoviamo (verrà "spostato" o "mergiato")
      newState.removeAt(index);
    }

    // 3. Cerchiamo se esiste già un item target con le NUOVE specifiche per fare Merge
    final targetIndex = newState.indexWhere((c) =>
    c.id == originalItem.id &&
        c.notes == newNote &&
        c.course == newCourse &&
        _areExtrasEqual(c.selectedExtras, newExtras)
    );

    if (targetIndex >= 0) {
      // MERGE: Esiste già un piatto uguale alla nuova configurazione, incrementiamo quello
      newState[targetIndex] = newState[targetIndex].copyWith(qty: newState[targetIndex].qty + 1);
    } else {
      // CREATE: Non esiste, creiamo una nuova riga
      final newItem = originalItem.copyWith(
          internalId: DateTime.now().millisecondsSinceEpoch, // Nuovo ID per distinguerlo
          qty: 1,
          notes: newNote,
          course: newCourse,
          selectedExtras: newExtras
      );
      newState.add(newItem);
    }

    // Aggiorniamo lo stato
    state = newState;
  }

  // Helper per confrontare liste di Extra (indipendentemente dall'ordine)
  bool _areExtrasEqual(List<Extra> a, List<Extra> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.id).toSet();
    final bIds = b.map((e) => e.id).toSet();
    return aIds.containsAll(bIds);
  }
}