import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:orderly/data/models/config/department.dart';
import 'package:orderly/data/models/config/table.dart';
import 'package:orderly/data/models/local/cart_entry.dart';
import 'package:orderly/data/models/menu/category.dart';
import 'package:orderly/data/models/menu/course.dart';
import 'package:orderly/data/models/menu/menu_item.dart';
import 'package:orderly/data/models/session/order.dart';
import 'package:orderly/data/models/session/void_record.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../core/services/tenant_service.dart';
import '../models/config/restaurant.dart';
import '../models/session/table_session.dart';
import '../models/user.dart';
import 'i_orderly_repository.dart';

class PocketBaseRepository implements IOrderlyRepository {
  late PocketBase _pb;

  // Costruttore privato per forzare l'uso del factory method `create`
  PocketBaseRepository._(String baseUrl) {
    _pb = PocketBase(baseUrl);
  }

  // Factory method per la creazione asincrona
  static Future<PocketBaseRepository> create() async {
    final tenantService = await TenantService.create();
    final url = tenantService.getSavedTenantUrl();
    if (url == null) {
      // Potremmo voler gestire questo caso in modo più robusto,
      // magari con uno stato di "non inizializzato" o un errore specifico.
      throw Exception(
          "Nessun tenant URL salvato. Impossibile inizializzare PocketBaseRepository.");
    }
    return PocketBaseRepository._(url);
  }

  /// Verifica se siamo connessi al server
  @override
  Future<bool> checkHealth() async {
    try {
      final health = await _pb.health.check();
      return health.code == 200;
    } catch (e) {
      return false;
    }
  }

  // --- AUTHENTICATION ---

  /// Esegue il login usando il PIN.
  /// Poiché PocketBase usa email/pass, qui usiamo una logica custom:
  /// 1. Hashiamo il PIN (SHA-256).
  /// 2. Cerchiamo un utente con quel pin_hash.
  /// 3. (Opzionale) Se PB lo richiede, potremmo fare authAsAdmin per operazioni privilegiate,
  ///    ma per ora simuliamo l'identità trovando il record utente.
  @override
  Future<User> loginWithPin(String pin) async {
    try {
      // 1. Hash del PIN
      final bytes = utf8.encode(pin);
      final hash = sha256.convert(bytes).toString();

      // 2. Cerca utente
      final result = await _pb.collection('users').getList(
            filter: 'pin_hash = "$hash"',
            perPage: 1,
          );

      if (result.items.isEmpty) {
        throw Exception('PIN non valido');
      }

      final userRecord = result.items.first;

      // Nota: In un setup reale, il backend dovrebbe restituire un token JWT
      // specifico per questo utente tramite una Cloud Function o auth custom.
      // Per questo MVP, ci "fidiamo" del client che ha trovato l'utente.

      return User.fromJson(userRecord.toJson());
    } catch (e) {
      throw Exception('Login fallito: $e');
    }
  }

  // --- RESTAURANT INFO ---
  @override
  Future<Restaurant> getRestaurantInfo() async {
    // Assume che ci sia un solo record nella collection 'restaurant'
    final records = await _pb.collection('restaurant').getList(perPage: 1);
    if (records.items.isNotEmpty) {
      return Restaurant.fromJson(records.items.first.toJson());
    }
    throw Exception('Configurazione ristorante non trovata');
  }

  // --- TABLES & SESSIONS ---

  /// Ottiene lo stream delle sessioni attive (Realtime)
  @override
  Stream<List<TableSession>> watchActiveSessions() async* {
    // TODO: implement watchActiveSessions
    throw UnimplementedError();
  }

  /// Recupera tutti i tavoli (sessions) aperti una tantum
  @override
  Future<List<TableSession>> getActiveSessions() async {
    final records = await _pb.collection('table_sessions').getFullList(
          filter: 'status != "closed"',
          expand: 'table',
        );
    return records.map((r) => TableSession.fromJson(r.toJson())).toList();
  }

  /// Apre un nuovo tavolo
  @override
  Future<TableSession> openTable(
      String tableId, int guests, String waiterId) async {
    final body = {
      'table': tableId,
      'guests': guests,
      'waiter': waiterId,
      'status': 'seated',
      'created': DateTime.now().toIso8601String(),
    };
    final record = await _pb.collection('table_sessions').create(body: body);
    return TableSession.fromJson(record.toJson());
  }

  @override
  Future<void> closeTableSession(String sessionId) {
    // TODO: implement closeTableSession
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> getCategories() {
    // TODO: implement getCategories
    throw UnimplementedError();
  }

  @override
  Future<List<Course>> getCourses() {
    // TODO: implement getCourses
    throw UnimplementedError();
  }

  @override
  Future<List<Department>> getDepartments() {
    // TODO: implement getDepartments
    throw UnimplementedError();
  }

  @override
  Future<List<MenuItem>> getMenuItems() {
    // TODO: implement getMenuItems
    throw UnimplementedError();
  }

  @override
  Future<void> sendOrder(
      {required String sessionId,
      required String waiterId,
      required List<CartEntry> items}) {
    // TODO: implement sendOrder
    throw UnimplementedError();
  }

  @override
  Future<TableSession> getTableSessionById(String id) {
    // TODO: implement getTableSessionById
    throw UnimplementedError();
  }

  @override
  Future<List<VoidRecord>> getVoidsForTableSession(String tableSessionId) {
    // TODO: implement getVoidsForTableSession
    throw UnimplementedError();
  }

  @override
  Future<Order> getOrderById(String orderId) {
    // TODO: implement getOrderById
    throw UnimplementedError();
  }

  @override
  Future<List<Order>> getOrdersForTableSession(String tableSessionId) {
    // TODO: implement getOrdersForTableSession
    throw UnimplementedError();
  }

  @override
  Future<List<Table>> getTables() {
    // TODO: implement getTables
    throw UnimplementedError();
  }

  @override
  Future<void> voidItem({required String sessionId, required String orderItemId, required int quantityToVoid, required String reasonId, required String voidedById, String? notes}) {
    // TODO: implement voidItem
    throw UnimplementedError();
  }
}
