import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/user.dart';
import 'package:orderly/data/models/config/restaurant.dart';

import '../../core/services/tenant_service.dart';
import 'repository_provider.dart';
// Importa il repositoryProvider creato sopra

// Stato snello: contiene solo i dati di dominio
class SessionState {
  final User? currentUser;
  final Restaurant? currentRestaurant;

  // Helper per sapere se sono loggato
  bool get isAuthenticated => currentUser != null;

  const SessionState({this.currentUser, this.currentRestaurant});

  SessionState copyWith({User? currentUser, Restaurant? currentRestaurant}) {
    return SessionState(
      currentUser: currentUser,
      currentRestaurant: currentRestaurant ?? this.currentRestaurant,
    );
  }
}

// Usiamo AsyncNotifier per gestire nativamente loading e error
class SessionNotifier extends AsyncNotifier<SessionState> {

  @override
  Future<SessionState> build() async {
    print("[SessionNotifier] Building initial session state...");

    // 1. Leggiamo il repository (che ora può essere null)
    final repository = await ref.watch(repositoryProvider.future);

    // 2. CONTROLLO IMMEDIATO
    // Se il repository è null, significa che manca la configurazione (Tenant).
    // Ritorniamo subito uno stato valido ma vuoto.
    // Questo imposterà isLoading = false e value = SessionState(vuoto).
    if (repository == null) {
      print("[SessionNotifier] Repository nullo -> Richiede Tenant Selection");
      return const SessionState(currentUser: null, currentRestaurant: null);
    }

    print("[SessionNotifier] Repository ok, scarico info ristorante...");

    // 3. Se il repository c'è, procediamo normalmente
    try {
      final restaurant = await repository.getRestaurantInfo();
      return SessionState(currentRestaurant: restaurant, currentUser: null);
    } catch (e) {
      print("[SessionNotifier] Errore fetch ristorante: $e");
      // Se fallisce la chiamata di rete, rilanciamo l'errore (qui il retry ha senso)
      rethrow;
    }
  }

  /// Esegue il login
  Future<void> login(String pin) async {
    // Imposta lo stato su "Loading" senza perdere i dati precedenti
    state = const AsyncLoading();

    // AsyncValue.guard gestisce try/catch automaticamente
    state = await AsyncValue.guard(() async {
      // Recupera il repo (siccome siamo nel metodo, usiamo read o watch future)
      final repository = await ref.read(repositoryProvider.future);

      final user = await repository?.loginWithPin(pin);

      // Manteniamo il ristorante che avevamo già caricato nel build()
      // Nota: state.value potrebbe essere null se il build ha fallito,
      // ma qui assumiamo sia andato a buon fine.
      final currentRestaurant = state.value?.currentRestaurant;

      return SessionState(
          currentUser: user,
          currentRestaurant: currentRestaurant
      );
    });
  }

  void logout() {
    if (state.value != null) {
      // Resettiamo solo l'utente, manteniamo il ristorante
      state = AsyncData(state.value!.copyWith(currentUser: null));
      // Nota: costringiamo currentUser a null passando null esplicitamente nel copyWith (va adattato il copyWith)
      // Oppure ricreiamo lo stato:
      // state = AsyncData(SessionState(currentRestaurant: state.value!.currentRestaurant));
    }
  }

  /// Configura il tenant (Ristorante) usando il TenantService esistente.
  Future<void> setTenant(String input) async {
    // 1. Mettiamo lo stato in loading per mostrare lo spinner nella UI
    state = const AsyncLoading();

    // 2. Usiamo AsyncValue.guard per gestire automaticamente try/catch degli errori
    state = await AsyncValue.guard(() async {

      // A. Istanziamo il tuo servizio
      final tenantService = await TenantService.create();

      // B. Risolviamo l'input (es. "DEV" -> localhost, "CODICE" -> API Cloud)
      // Se fallisce, lancerà un'eccezione che finirà nello stato (AsyncError)
      final resolvedUrl = await tenantService.lookupTenant(input);

      // C. Salviamo l'URL risolto su Hive
      await tenantService.saveTenantUrl(resolvedUrl);

      // D. STEP FONDAMENTALE: Invalidiamo il repositoryProvider.
      // Questo costringe Riverpod a buttare via la vecchia istanza (che non aveva l'URL)
      // e a crearne una nuova. La nuova istanza leggerà l'URL appena salvato su Hive.
      ref.invalidate(repositoryProvider);

      // E. Attendiamo che il nuovo repository sia pronto e connesso
      final newRepository = await ref.read(repositoryProvider.future);

      // F. Scarichiamo le info aggiornate del ristorante
      final restaurant = await newRepository?.getRestaurantInfo();

      // G. Ritorniamo il nuovo stato: Tenant configurato, ma nessun utente loggato.
      return SessionState(
          currentUser: null,
          currentRestaurant: restaurant
      );
    });
  }

  /// Metodo opzionale per disconnettersi dal ristorante (es. cambio locale)
  Future<void> clearTenant() async {
    state = const AsyncLoading();
    final tenantService = await TenantService.create();
    await tenantService.clearTenant();

    // Ricaricando il repositoryProvider ora, fallirà (perché non c'è URL),
    // portando l'app allo stato di errore che il Router reindirizzerà a /tenant-selection
    ref.invalidate(repositoryProvider);

    // Forziamo un ricaricamento dello stato
    ref.invalidateSelf();
  }
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);