import 'dart:convert';
import 'package:hive_ce/hive_ce.dart';
import 'package:http/http.dart' as http;
import 'package:orderly/config/hive_keys.dart';

class TenantService {
  static const String _storageKey = 'orderly_tenant_url';

  // URL del sistema centrale Orderly che mappa Codice -> URL PocketBase
  static const String _discoveryApiUrl = 'https://admin.orderly.cloud/api/collections/tenants/records';

  final Box _box;

  // Costruttore privato
  TenantService._(this._box);

  // Factory method per la creazione asincrona
  static Future<TenantService> create() async {
    final box = await Hive.openBox(HiveKeys.settingsBox);
    print("[TenantService] Hive box 'app_settings' opened.");
    return TenantService._(box);
  }

  /// Cerca l'URL salvato localmente nel box Hive
  String? getSavedTenantUrl() {
    return _box.get(_storageKey) as String?;
  }

  /// Salva l'URL del tenant su Hive
  Future<void> saveTenantUrl(String url) async {
    await _box.put(_storageKey, url);
  }

  /// Cancella l'URL (Logout Ristorante)
  Future<void> clearTenant() async {
    await _box.delete(_storageKey);
  }

  /// Logica intelligente per risolvere l'input dell'utente
  Future<String> lookupTenant(String input) async {
    final code = input.trim();

    try {
      // CASO 1: Sviluppo Locale (Emulatori)
      if (code.toUpperCase() == 'DEV') {
        return 'http://127.0.0.1:8090';
      }

      // CASO 2: IP Diretto o URL Completo (Es. per tablet reali in LAN)
      // Se contiene 'http' o sembra un IP (inizia con numeri), lo usiamo direttamente.
      if (code.startsWith('http') || RegExp(r'^\d{1,3}\.\d{1,3}\.').hasMatch(code)) {
        String url = code;
        if (!url.startsWith('http')) {
          url = 'http://$code';
        }
        // Se l'utente non ha messo la porta e sembra un IP locale, potremmo assumere :8090
        // ma per ora lasciamo flessibilità totale.
        return url;
      }

      // CASO 3: Tenant Discovery (Cloud)
      // Se è un codice, chiamiamo l'API di discovery.
      final response = await http.get(
        Uri.parse('$_discoveryApiUrl?filter=(code="$code")'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List;
        if (items.isNotEmpty) {
          final tenantUrl = items.first['host_url'];
          return tenantUrl;
        } else {
          throw Exception('Ristorante non trovato');
        }
      } else {
        throw Exception('Errore di connessione al server centrale');
      }
    } catch (e) {
      throw Exception('Impossibile connettersi: $e');
    }
  }
}