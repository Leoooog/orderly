import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/logic/providers/session_provider.dart'; // Assicurati che il path sia giusto
import 'package:orderly/modules/waiter/screens/login_screen.dart';
import 'package:orderly/shared/widgets/splash_screen.dart';
import 'package:orderly/shared/widgets/tenant_selection_screen.dart';

// Importa le tue schermate
import '../screens/menu_view.dart';
import '../screens/settings_screen.dart';
import '../screens/success_view.dart';
import '../screens/tables_view.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
GlobalKey<NavigatorState>(debugLabel: 'shell');

final waiterRouterProvider = Provider<GoRouter>((ref) {
  // Notifier per forzare il refresh quando cambia lo stato della sessione
  final refreshNotifier = ValueNotifier<int>(0);

  ref.listen(sessionProvider, (_, next) {
    refreshNotifier.value++;
  });

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final sessionAsync = ref.read(sessionProvider);
      final location = state.uri.toString();

      // ---------------------------------------------------------
      // 1. STATO DI CARICAMENTO
      // ---------------------------------------------------------
      if (sessionAsync.isLoading) {
        // Se stiamo andando verso splash, lasciamo fare, altrimenti forziamo splash
        print("[Router] Session is loading, redirecting to /splash");
        return location == '/splash' ? null : '/splash';

      }

      // ---------------------------------------------------------
      // 2. GESTIONE ERRORI / MANCANZA CONFIGURAZIONE
      // ---------------------------------------------------------
      // Verifica A: Il provider ha lanciato un errore specifico
      final hasConfigError = sessionAsync.hasError &&
          (sessionAsync.error.toString().contains('TENANT_NOT_CONFIGURED') ||
              sessionAsync.error.toString().contains('BACKEND_NOT_CONFIGURED'));

      // Verifica B: Il provider ha restituito uno stato valido ma senza Ristorante (Il fix che abbiamo discusso prima)
      final isUnconfiguredState = sessionAsync.value != null &&
          sessionAsync.value!.currentRestaurant == null;

      // Se manca la configurazione (per errore o per stato vuoto), vai a Tenant Selection
      if (hasConfigError || isUnconfiguredState) {
        print("[Router] Tenant not configured, redirecting to /tenant-selection");
        return location == '/tenant-selection' ? null : '/tenant-selection';
      }

      // Se c'è un errore generico diverso (es. crash server), rimaniamo qui o su splash
      if (sessionAsync.hasError) return null;

      // ---------------------------------------------------------
      // 3. STATO DATI PRONTI (Abbiamo un Ristorante)
      // ---------------------------------------------------------
      final session = sessionAsync.value;
      if (session == null) return '/splash'; // Safety fallback

      print("[Router] Session ready, user authenticated: ${session.currentUser != null}");

      final isAuthenticated = session.currentUser != null;
      final isLoginScreen = location == '/login';
      final isTenantScreen = location == '/tenant-selection';
      final isSplashScreen = location == '/splash';

      // CASO A: Non autenticato -> Login
      // Nota: Arriviamo qui solo se il Ristorante ESISTE (step 2 passato), quindi è sicuro forzare il login.
      if (!isAuthenticated) {
        return isLoginScreen ? null : '/login';
      }

      // CASO B: Autenticato -> Home (Tables)
      // Se l'utente è loggato ma prova ad andare su pagine di "servizio" (login, splash, tenant),
      // lo riportiamo alla home.
      if (isLoginScreen || isTenantScreen || isSplashScreen) {
        return '/tables';
      }

      // In tutti gli altri casi (navigazione interna consentita), null.
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (_, __) => '/tables',
      ),
      GoRoute(
        path: '/tenant-selection',
        builder: (context, state) => const TenantSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(body: child);
        },
        routes: [
          GoRoute(
            path: '/tables',
            pageBuilder: (context, state) =>
            const NoTransitionPage(child: TablesView()),
          ),
          GoRoute(
            path: '/menu/:tableId',
            name: 'menu',
            pageBuilder: (context, state) {
              final tableId = state.pathParameters['tableId']!;
              return NoTransitionPage(
                  child: MenuView(
                    tableSessionId: tableId,
                  ));
            },
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
            const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
      GoRoute(
          path: '/success/:tableName',
          name: 'success',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final tableName = state.pathParameters['tableName']!;
            return SuccessView(tableName: tableName);
          }),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refreshNotifier.dispose();
  });

  return router;
});