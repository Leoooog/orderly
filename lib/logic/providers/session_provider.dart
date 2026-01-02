import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:orderly/data/repositories/i_orderly_repository.dart';

import '../../config/hive_keys.dart';
import '../../core/services/repository_factory.dart';
import '../../core/services/tenant_service.dart';
import '../../data/models/config/restaurant.dart';
import '../../data/models/user.dart';

enum AppState {
  initializing, // Caricamento iniziale del repository
  backendSelection, // Scelta del backend (se non configurato)
  tenantSetup, // Inserimento codice/URL del tenant
  tenantError, // Errore di connessione al tenant
  loginRequired, // Repository pronto, serve PIN
  authenticated, // Utente loggato
}

class SessionState {
  final AppState appState;
  final bool isLoading;
  final String? errorMessage;
  final Restaurant? currentRestaurant;
  final User? currentUser;
  final IOrderlyRepository? repository;

  const SessionState({
    this.appState = AppState.initializing,
    this.isLoading = true,
    this.errorMessage,
    this.currentRestaurant,
    this.currentUser,
    this.repository,
  });

  SessionState copyWith({
    AppState? appState,
    bool? isLoading,
    String? errorMessage,
    Restaurant? currentRestaurant,
    User? currentUser,
    IOrderlyRepository? repository,
    bool clearCurrentUser = false,
  }) {
    return SessionState(
      appState: appState ?? this.appState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentRestaurant: currentRestaurant ?? this.currentRestaurant,
      currentUser: clearCurrentUser ? null : currentUser ?? this.currentUser,
      repository: repository ?? this.repository,
    );
  }
}

final sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

class SessionNotifier extends Notifier<SessionState> {
  late final RepositoryFactory _repoFactory;

  @override
  SessionState build() {
    // Schedule the async initialization to run after the build method completes.
    Future.microtask(() => _init());
    return const SessionState();
  }

  Future<void> _init() async {
    print("[Session] Initializing...");
    _repoFactory = RepositoryFactory();

    // Controlla se un backend è stato configurato per decidere lo stato iniziale.
    // Apriamo il box qui solo per questa verifica iniziale.
    final settingsBox = Hive.box(HiveKeys.settingsBox);
    final backendType = settingsBox.get(HiveKeys.backendType);
    if (backendType == null) {
      print("[Session] No backend configured. Moving to BackendSelection.");
      state = state.copyWith(
          appState: AppState.backendSelection, isLoading: false);
      return;
    }
    print("[Session] Backend configured: $backendType. Loading repository...");
    await _loadRepository();
  }

  Future<void> _loadRepository() async {
    print("[Session] Loading repository...");
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = await _repoFactory.createRepository();
      final restaurant = await repo.getRestaurantInfo();

      print("[Session] Repository loaded. Restaurant: ${restaurant.name}. Moving to LoginRequired.");
      state = state.copyWith(
        repository: repo,
        currentRestaurant: restaurant,
        appState: AppState.loginRequired,
        isLoading: false,
      );
    } catch (e) {
      print("[Session] Error loading repository: $e. Moving to TenantSetup.");
      // Se il repo non si crea (es. no URL), andiamo al setup del tenant
      state = state.copyWith(
        appState: AppState.tenantSetup,
        isLoading: false,
        errorMessage:
            "Configurazione del ristorante richiesta. ${e.toString()}",
      );
    }
  }

  Future<void> setBackend(String backendType) async {
    print("[Session] Setting backend to: $backendType");
    await _repoFactory.setBackendType(backendType);
    await _loadRepository();
  }

  Future<void> setTenant(String code) async {
    print("[Session] Setting tenant with code: $code");
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Il TenantService ora è usato internamente dal repo,
      // ma per impostare un NUOVO tenant, abbiamo bisogno di un modo.
      // Soluzione: usiamo un TenantService temporaneo qui solo per questo scopo.
      final tenantService = await TenantService.create();
      final url = await tenantService.lookupTenant(code);
      await tenantService.saveTenantUrl(url);

      print("[Session] Tenant URL saved: $url. Reloading repository.");
      // Ora che l'URL è salvato, ricarichiamo il repository
      await _loadRepository();
    } catch (e) {
      print("[Session] Error setting tenant: $e");
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        appState: AppState.tenantSetup,
      );
    }
  }

  Future<void> login(String pin) async {
    if (state.repository == null) {
      print("[Session] Login attempt failed: repository is null.");
      return;
    }
    print("[Session] Attempting login...");
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await state.repository!.loginWithPin(pin);
      print("[Session] Login successful for user: ${user.name}. Moving to Authenticated.");
      state = state.copyWith(
        isLoading: false,
        currentUser: user,
        appState: AppState.authenticated,
      );
    } catch (e) {
      print("[Session] Login failed: $e");
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login fallito: ${e.toString()}',
      );
    }
  }

  void logout() {
    print("[Session] Logging out. Moving to LoginRequired.");
    state = state.copyWith(
      clearCurrentUser: true, // Resetta l'utente
      appState: AppState.loginRequired,
    );
  }

  Future<void> clearTenant() async {
    print("[Session] Clearing tenant. Moving to TenantSetup.");
    final tenantService = await TenantService.create();
    await tenantService.clearTenant();
    state = const SessionState(
      appState: AppState.tenantSetup,
      isLoading: false,
    );
  }
}