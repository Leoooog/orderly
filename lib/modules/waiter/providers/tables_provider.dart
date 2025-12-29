import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/table_item.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/mock_data.dart'; // Importiamo i dati iniziali

// 1. IL PROVIDER (Sintassi Riverpod 2.0)
// Espone la lista dei tavoli a tutta l'app utilizzando NotifierProvider
final tablesProvider = NotifierProvider<TablesNotifier, List<TableItem>>(TablesNotifier.new);

// 2. IL NOTIFIER (LA LOGICA)
// Estende Notifier invece di StateNotifier
class TablesNotifier extends Notifier<List<TableItem>> {

  // Il metodo build() sostituisce il costruttore per l'inizializzazione dello stato
  @override
  List<TableItem> build() {
    return globalTables;
  }

  // --- AZIONI ---

  // Apri un tavolo (imposta ospiti e stato)
  void occupyTable(int tableId, int guests) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          TableItem(
            id: table.id,
            name: table.name,
            status: 'occupied',
            guests: guests,
            orders: table.orders, // Mantiene eventuali ordini precedenti
          )
        else
          table
    ];
  }

  // Aggiungi nuovi ordini a un tavolo (quando premi "INVIA CUCINA")
  void addOrdersToTable(int tableId, List<CartItem> newOrders) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _addOrdersToTableInstance(table, newOrders)
        else
          table
    ];
  }

  // Helper per creare una nuova istanza tavolo con ordini aggiornati
  TableItem _addOrdersToTableInstance(TableItem table, List<CartItem> newOrders) {
    // Clona la lista attuale per non modificare il riferimento precedente
    final currentOrders = List<CartItem>.from(table.orders);
    currentOrders.addAll(newOrders);

    return TableItem(
      id: table.id,
      name: table.name,
      status: 'occupied',
      guests: table.guests,
      orders: currentOrders,
    );
  }

  // Sposta Tavolo (Source -> Target)
  void moveTable(int sourceId, int targetId) {
    final sourceTable = state.firstWhere((t) => t.id == sourceId);

    state = [
      for (final table in state)
        if (table.id == targetId)
        // Il target eredita tutto dal source
          TableItem(
            id: table.id,
            name: table.name,
            status: 'occupied',
            guests: sourceTable.guests,
            orders: List.from(sourceTable.orders),
          )
        else if (table.id == sourceId)
        // Il source si resetta
          TableItem(
            id: table.id,
            name: table.name,
            status: 'free',
            guests: 0,
            orders: [],
          )
        else
          table
    ];
  }

  // Unisci Tavoli (Source -> Target)
  void mergeTable(int sourceId, int targetId) {
    final sourceTable = state.firstWhere((t) => t.id == sourceId);

    state = [
      for (final table in state)
        if (table.id == targetId)
        // Il target somma i dati del source
          TableItem(
            id: table.id,
            name: table.name,
            status: 'occupied',
            guests: table.guests + sourceTable.guests,
            orders: [...table.orders, ...sourceTable.orders],
          )
        else if (table.id == sourceId)
        // Il source si libera
          TableItem(
            id: table.id,
            name: table.name,
            status: 'free',
            guests: 0,
            orders: [],
          )
        else
          table
    ];
  }

  // Gestione Pagamento (Parziale o Totale)
  void processPayment(int tableId, List<CartItem> paidItems) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          _calculateRemainingTable(table, paidItems)
        else
          table
    ];
  }

  TableItem _calculateRemainingTable(TableItem table, List<CartItem> paidItems) {
    final remainingOrders = List<CartItem>.from(table.orders);

    for (var paid in paidItems) {
      final index = remainingOrders.indexWhere((o) => o.internalId == paid.internalId);
      if (index != -1) {
        remainingOrders[index].qty -= paid.qty;
      }
    }

    // Rimuovi item con quantità 0
    remainingOrders.removeWhere((o) => o.qty <= 0);

    // Se non ci sono più ordini, il tavolo torna libero
    final isFree = remainingOrders.isEmpty;

    return TableItem(
      id: table.id,
      name: table.name,
      status: isFree ? 'free' : 'occupied',
      guests: isFree ? 0 : table.guests,
      orders: remainingOrders,
    );
  }
}