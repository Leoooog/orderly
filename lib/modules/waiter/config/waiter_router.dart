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

final waiterRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);

  ref.listen(sessionProvider, (_, next) {
    refreshNotifier.value++;
  });

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,

    // --- LOGICA DI REDIRECT (Invariata, è perfetta) ---
    redirect: (BuildContext context, GoRouterState state) {
      final sessionAsync = ref.read(sessionProvider);
      final location = state.uri.toString();

      if (sessionAsync.isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      final hasConfigError = sessionAsync.hasError &&
          (sessionAsync.error.toString().contains('TENANT_NOT_CONFIGURED') ||
              sessionAsync.error.toString().contains('BACKEND_NOT_CONFIGURED'));
      final isUnconfiguredState = sessionAsync.value != null &&
          sessionAsync.value!.currentRestaurant == null;

      if (hasConfigError || isUnconfiguredState) {
        return location == '/tenant-selection' ? null : '/tenant-selection';
      }

      if (sessionAsync.hasError) return null;

      final session = sessionAsync.value;
      if (session == null) return '/splash';

      final isAuthenticated = session.currentUser != null;
      final isLoginScreen = location == '/login';
      final isTenantScreen = location == '/tenant-selection';
      final isSplashScreen = location == '/splash';

      if (!isAuthenticated) {
        return isLoginScreen ? null : '/login';
      }

      if (isLoginScreen || isTenantScreen || isSplashScreen) {
        return '/tables';
      }

      return null;
    },

    // --- ROUTE PIATTE (Senza Shell) ---
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

      // Ho spostato queste route fuori dalla ShellRoute, ora sono al livello principale
      GoRoute(
        path: '/tables',
        // Uso pageBuilder con NoTransitionPage se vuoi mantenere l'effetto "fermo"
        // o builder normale se vuoi l'animazione di slide nativa.
        pageBuilder: (context, state) =>
        const NoTransitionPage(child: TablesView()),
      ),
      GoRoute(
        path: '/menu/:tableId',
        name: 'menu',
        builder: (context, state) {
          final tableId = state.pathParameters['tableId']!;
          return MenuView(tableSessionId: tableId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
          path: '/success/:tableName',
          name: 'success',
          builder: (context, state) {
            final tableName = state.pathParameters['tableName']!;
            return SuccessView(tableName: tableName);
          },

      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refreshNotifier.dispose();
  });

  return router;
});