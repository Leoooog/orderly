import 'package:orderly/data/models/config/restaurant.dart';
import 'package:orderly/data/models/config/void_reason.dart';
import 'package:orderly/data/models/session/order.dart';
import 'package:orderly/data/models/session/table_session.dart';
import 'package:orderly/data/models/user.dart';

import '../models/config/department.dart';
import '../models/config/table.dart';
import '../models/enums/order_item_status.dart';
import '../models/local/cart_entry.dart';
import '../models/menu/category.dart';
import '../models/menu/course.dart';
import '../models/menu/menu_item.dart';

/// Defines the contract for data operations within the Orderly app.
/// This interface abstracts the data source, allowing for different implementations (e.g., PocketBase, Firebase, Mock).
abstract class IOrderlyRepository {
  // --- Auth & Config ---

  /// Esegue il login dello staff tramite PIN.
  Future<User> loginWithPin(String pin);

  /// Recupera le informazioni di base del ristorante.
  Future<Restaurant> getRestaurantInfo();

  // --- Master Data (Dati di configurazione) ---

  /// Recupera la lista statica di tutti i tavoli fisici del ristorante.
  Future<List<Table>> getTables();

  /// Recupera tutte le categorie del menu.
  Future<List<Category>> getCategories();

  /// Recupera tutti i piatti disponibili.
  Future<List<MenuItem>> getMenuItems();

  /// Recupera le portate (es. Antipasti, Primi).
  Future<List<Course>> getCourses();

  /// Recupera i dipartimenti di produzione (es. Cucina, Bar).
  Future<List<Department>> getDepartments();

  /// Recupera le motivazioni di storno predefinite.
  Future<List<VoidReason>> getVoidReasons();

  // --- Realtime Data Streams ---

  /// Stream che emette la lista aggiornata delle sessioni tavolo attive (status != 'closed').
  Stream<List<TableSession>> watchActiveSessions();

  /// Stream che emette la lista aggiornata di tutti gli ordini del turno corrente.
  Stream<List<Order>> watchActiveOrders();

  // --- Actions ---

  /// Apre un nuovo tavolo (crea una `TableSession`).
  Future<void> openTable(String tableId, int guests, String waiterId);

  /// Chiude definitivamente una sessione tavolo.
  Future<void> closeTableSession(String sessionId);

  /// Invia una nuova comanda (crea record `Order` e `OrderItem`).
  Future<void> sendOrder({
    required String sessionId,
    required String waiterId,
    required List<CartEntry> items,
  });

  /// Registra uno storno.
  Future<void> voidItem(
      {required String orderItemId,
        required VoidReason reason,
        required int quantity,
        required bool refund,
        required String voidedBy,
        String? notes});

  /// Sposta una sessione da un tavolo a un altro (libero).
  Future<void> moveTable(String sourceSessionId, String targetTableId);

  /// Unisce due sessioni tavolo.
  Future<void> mergeTable(String sourceSessionId, String targetSessionId);

  /// Gestisce il pagamento (parziale o totale) di una lista di `OrderItem`.
  Future<void> processPayment(
      String tableSessionId, List<String> orderItemIds);

  /// Aggiorna lo stato di un singolo OrderItem.
  Future<void> updateOrderItemStatus(String orderItemId, OrderItemStatus status);

  /// Aggiorna i dettagli di un OrderItem.
  Future<void> updateOrderItem({
    required String orderItemId,
    required int newQty,
    required String newNote,
    required String newCourseId,
    required List<String> newExtrasIds,
  });
}