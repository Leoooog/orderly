import 'package:orderly/data/models/config/restaurant.dart';
import 'package:orderly/data/models/session/order.dart';
import 'package:orderly/data/models/session/table_session.dart';
import 'package:orderly/data/models/session/void_record.dart';
import 'package:orderly/data/models/user.dart';

import '../models/config/department.dart';
import '../models/config/table.dart';
import '../models/local/cart_entry.dart';
import '../models/menu/category.dart';
import '../models/menu/course.dart';
import '../models/menu/menu_item.dart';
abstract class IOrderlyRepository {
  // --- Auth & Config ---
  /// Verifica se il server è raggiungibile
  Future<bool> checkHealth();

  /// Esegue il login dello staff tramite PIN (hash SHA-256)
  Future<User> loginWithPin(String pin);

  /// Recupera le informazioni del ristorante (nome, valuta, ecc.)
  Future<Restaurant> getRestaurantInfo();

  // --- Master Data (Menu & Struttura) ---
  /// Recupera tutte le categorie del menu
  Future<List<Category>> getCategories();

  /// Recupera tutti i piatti disponibili (con relazioni espande)
  Future<List<MenuItem>> getMenuItems();

  /// Recupera le portate (Courses)
  Future<List<Course>> getCourses();

  /// Recupera i dipartimenti (Cucina, Bar, ecc.)
  Future<List<Department>> getDepartments();

  /// Recupera la lista statica di tutti i tavoli fisici del ristorante
  Future<List<Table>> getTables();

  // --- Realtime ---
  /// Stream che emette la lista aggiornata delle sessioni tavolo attive
  Stream<List<TableSession>> watchActiveSessions();

  // --- Tables & Sessions ---
  /// Recupera una tantum la lista delle sessioni attive
  Future<List<TableSession>> getActiveSessions();

  /// Recupera una sessione specifica per ID
  Future<TableSession> getTableSessionById(String id);

  /// Apre un nuovo tavolo (crea una TableSession)
  Future<TableSession> openTable(String tableId, int guests, String waiterId);

  /// Chiude definitivamente una sessione tavolo
  Future<void> closeTableSession(String sessionId);

  /// Recupera gli ordini associati a una sessione tavolo
  Future<List<Order>> getOrdersForTableSession(String tableSessionId);

  /// Recupera i dettagli di un ordine specifico
  Future<Order> getOrderById(String orderId);

  // --- Orders ---
  /// Invia un ordine completo (crea Order record + OrderItems records)
  Future<void> sendOrder({
    required String sessionId,
    required String waiterId,
    required List<CartEntry> items,
  });

  // --- Voids & Cancellations (Giorno 4) ---
  /// Recupera lo storico degli storni per una sessione
  Future<List<VoidRecord>> getVoidsForTableSession(String tableSessionId);

  /// Registra uno storno: crea un record in 'voids' e aggiorna l'OrderItem originale
  /// (riducendo la quantità o cambiandone lo stato)
  Future<void> voidItem({
    required String sessionId,
    required String orderItemId,
    required int quantityToVoid,
    required String reasonId,
    required String voidedById,
    String? notes,
  });

// --- Payments (Giorno 4) ---
// Future<Payment> registerPayment(...) // Da definire nel dettaglio successivamente
}