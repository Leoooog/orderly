import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/logic/providers/session_provider.dart';
import 'package:orderly/modules/waiter/screens/login_screen.dart';
import 'package:orderly/shared/widgets/tenant_selection_screen.dart';

import '../screens/menu_view.dart';
import '../screens/settings_screen.dart';
import '../screens/success_view.dart';
import '../screens/tables_view.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final waiterRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);


  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/tables',
    redirect: (BuildContext context, GoRouterState state) {
      final appState = session.appState;
      final location = state.uri.toString();

      // Se stiamo inizializzando, non fare nulla, mostrerà una schermata vuota
      if (appState == AppState.initializing) {
        return null; // o una rotta di loading se preferisci
      }

      final isTenantScreen = location.startsWith('/tenant-selection');
      final isLoginScreen = location.startsWith('/login');

      // Se il tenant non è configurato, forza la schermata di selezione
      if (appState == AppState.tenantSetup ||
          appState == AppState.tenantError) {
        return isTenantScreen ? null : '/tenant-selection';
      }

      // Se il repo è pronto ma non siamo loggati, forza la schermata di login
      if (appState == AppState.loginRequired) {
        return isLoginScreen ? null : '/login';
      }

      // Se siamo autenticati e ci troviamo su login o tenant, vai alla home
      if (appState == AppState.authenticated &&
          (isLoginScreen || isTenantScreen)) {
        return '/tables';
      }

      // In tutti gli altri casi, lascia che l'utente vada dove ha chiesto
      return null;
    },
    routes: [
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
        builder: (context, state) => LoginScreen(
          onLoginSuccess: () {
            // Il redirect farà il suo lavoro, non serve forzare la navigazione qui
          },
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(body: child); // Un semplice Scaffold per ora
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
});

// Helper per ascoltare i cambiamenti di stato e aggiornare il router
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
