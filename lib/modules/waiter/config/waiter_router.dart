import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:orderly/logic/providers/session_provider.dart';
import 'package:orderly/modules/waiter/screens/login_screen.dart';
import 'package:orderly/shared/widgets/splash_screen.dart';
import 'package:orderly/shared/widgets/tenant_selection_screen.dart';

import '../../../config/hive_keys.dart';
import '../screens/menu_view.dart';
import '../screens/settings_screen.dart';
import '../screens/success_view.dart';
import '../screens/tables_view.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final waiterRouterProvider = Provider<GoRouter>((ref) {
  // Create a ValueNotifier to notify the router when the session state changes.
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, __) {
    // When the session state changes, update the notifier's value
    // to trigger the router's refresh.
    refreshNotifier.value++;
  });

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      // Read the latest session state directly from the provider.
      final appState = ref.read(sessionProvider).appState;
      final location = state.uri.toString();
      final isSplash = location == '/splash';

      // If the app is initializing, stay on the splash screen.
      if (appState == AppState.initializing) {
        return isSplash ? null : '/splash';
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

      if (appState == AppState.backendSelection) {
        // Salviamo "DEV" in Hive come backend selezionato
        ref.read(sessionProvider.notifier).setBackend('pocketbase');
        return '/splash';
      }

      // In tutti gli altri casi, lascia che l'utente vada dove ha chiesto
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

  ref.onDispose(() {
    router.dispose();
    refreshNotifier.dispose();
  });

  return router;
});
