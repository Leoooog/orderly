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
    _init();
    return const SessionState();
  }

  Future<void> _init() async {
    _repoFactory = RepositoryFactory();

    // Controlla se un backend è stato configurato per decidere lo stato iniziale.
    // Apriamo il box qui solo per questa verifica iniziale.
    final settingsBox = await Hive.openBox(HiveKeys.settingsBox);
    final backendType = settingsBox.get(HiveKeys.backendType);
    if (backendType == null) {
      state = state.copyWith(
          appState: AppState.backendSelection, isLoading: false);
      return;
    }

    await _loadRepository();
  }

  Future<void> _loadRepository() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = await _repoFactory.createRepository();
      final restaurant = await repo.getRestaurantInfo();

      state = state.copyWith(
        repository: repo,
        currentRestaurant: restaurant,
        appState: AppState.loginRequired,
        isLoading: false,
      );
    } catch (e) {
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
    await _repoFactory.setBackendType(backendType);
    await _loadRepository();
  }

  Future<void> setTenant(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Il TenantService ora è usato internamente dal repo,
      // ma per impostare un NUOVO tenant, abbiamo bisogno di un modo.
      // Soluzione: usiamo un TenantService temporaneo qui solo per questo scopo.
      final tenantService = await TenantService.create();
      final url = await tenantService.lookupTenant(code);
      await tenantService.saveTenantUrl(url);

      // Ora che l'URL è salvato, ricarichiamo il repository
      await _loadRepository();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        appState: AppState.tenantSetup,
      );
    }
  }

  Future<void> login(String pin) async {
    if (state.repository == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await state.repository!.loginWithPin(pin);
      state = state.copyWith(
        isLoading: false,
        currentUser: user,
        appState: AppState.authenticated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login fallito: ${e.toString()}',
      );
    }
  }

  void logout() {
    state = state.copyWith(
      clearCurrentUser: true, // Resetta l'utente
      appState: AppState.loginRequired,
    );
  }

  Future<void> clearTenant() async {
    final tenantService = await TenantService.create();
    await tenantService.clearTenant();
    state = const SessionState(
      appState: AppState.tenantSetup,
      isLoading: false,
    );
  }
}