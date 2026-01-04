import 'package:orderly/data/models/config/restaurant.dart';
import 'package:orderly/data/models/config/void_reason.dart';
import 'package:orderly/data/models/menu/ingredient.dart';
import 'package:orderly/data/models/session/order.dart';
import 'package:orderly/data/models/session/table_session.dart';
import 'package:orderly/data/models/user.dart';

import '../models/config/department.dart';
import '../models/config/table.dart';
import '../models/enums/order_item_status.dart';
import '../models/local/cart_entry.dart';
import '../models/menu/category.dart';
import '../models/menu/course.dart';
import '../models/menu/extra.dart';
import '../models/menu/menu_item.dart';
import '../models/session/order_item.dart';

/// Contratto per le operazioni sui dati dell'applicazione Orderly.
///
/// Questa interfaccia astrae la sorgente dati (PocketBase, Firebase, Mock),
/// gestendo Autenticazione, Configurazione, Dati Master e Operazioni Realtime.
abstract class IOrderlyRepository {

  // ===========================================================================
  // AUTHENTICATION & CONFIGURATION
  // ===========================================================================

  /// Esegue il login dello staff tramite PIN.
  Future<User> loginWithPin(String pin);

  /// Recupera le informazioni globali del ristorante (valuta, nome, impostazioni).
  Future<Restaurant> getRestaurantInfo();

  // ===========================================================================
  // MASTER DATA (Dati Statici / Menu)
  // ===========================================================================

  /// Recupera la lista dei tavoli fisici.
  Future<List<Table>> getTables();

  /// Recupera le categorie del menu (es. Antipasti, Primi).
  Future<List<Category>> getCategories();

  /// Recupera il listino completo dei piatti con i dettagli (ingredienti, prezzi).
  Future<List<MenuItem>> getMenuItems();

  /// Recupera l'ordine delle portate per la stampa/visualizzazione.
  Future<List<Course>> getCourses();

  /// Recupera i dipartimenti di produzione (Cucina, Bar, Pizzeria).
  Future<List<Department>> getDepartments();

  /// Recupera le causali di storno predefinite.
  Future<List<VoidReason>> getVoidReasons();

  // ===========================================================================
  // REALTIME STREAMS
  // ===========================================================================

  /// Emette la lista aggiornata delle sessioni tavolo aperte.
  Stream<List<TableSession>> watchActiveSessions();

  /// Emette la lista di tutti gli ordini attivi (non ancora archiviati).
  Stream<List<Order>> watchActiveOrders();

  /// Emette la lista piatta di tutti gli item attivi (utile per Kitchen Display System).
  Stream<List<OrderItem>> watchAllActiveOrderItems();

  // ===========================================================================
  // OPERATIONAL ACTIONS (Azioni)
  // ===========================================================================

  /// Apre un nuovo tavolo.
  /// Restituisce la [TableSession] creata per permettere la navigazione immediata.
  Future<TableSession> openTable(String tableId, int guests, String waiterId);

  /// Chiude definitivamente una sessione tavolo (Checkout completato).
  Future<void> closeTableSession(String sessionId);

  /// Invia una nuova comanda.
  /// Restituisce l'[Order] creato per conferme o riferimenti UI.
  Future<Order> sendOrder({
    required String sessionId,
    required String waiterId,
    required List<CartEntry> items,
  });

  /// Registra lo storno di un item specifico.
  ///
  /// Richiede i dati "snapshot" dell'item al momento dello storno per audit.
  Future<void> voidItem({
    required String orderItemId,
    required VoidReason reason,
    required String tableSessionId,
    required String menuItemId,
    required String menuItemName,
    required double amount,
    required int quantity,
    required bool refund,
    required String voidedBy,
    required OrderItemStatus statusWhenVoided,
    String? notes,
  });

  /// Sposta una sessione da un tavolo (source) a un altro libero (target).
  Future<void> moveTable(String sourceSessionId, String targetTableId);

  /// Unisce due sessioni tavolo (es. unire due tavoli vicini).
  Future<void> mergeTable(String sourceSessionId, String targetSessionId);

  /// Gestisce il pagamento (parziale o totale) di una lista di ID [OrderItem].
  Future<void> processPayment(String tableSessionId, List<String> orderItemIds);

  /// Aggiorna lo stato operativo di un singolo OrderItem (es. In Attesa -> In Preparazione).
  Future<void> updateOrderItemStatus(List<String> orderItemIds, OrderItemStatus status);

  /// Aggiorna la configurazione di un OrderItem esistente (es. cambio note, extra o quantità).
  Future<void> updateOrderItem({
    required String orderItemId,
    required int newQty,
    required String newNotes,
    required Course newCourse,
    required List<Extra> newExtras,
    required List<Ingredient> newRemovedIngredients,
  });

}