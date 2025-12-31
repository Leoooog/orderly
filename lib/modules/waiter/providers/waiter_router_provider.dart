import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screens (Import relativi interni al modulo)
import '../screens/login_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tables_view.dart';
import '../screens/menu_view.dart';
import '../screens/success_view.dart';

// Providers (Import relativi interni al modulo)
import 'auth_provider.dart';
import 'tables_provider.dart';

// Chiave globale per la navigazione
final _waiterNavigatorKey = GlobalKey<NavigatorState>();

final waiterRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _waiterNavigatorKey,
    initialLocation: '/tables',

    // Logica di Reindirizzamento (Guardia) specifica per i camerieri
    redirect: (context, state) {
      final bool loggingIn = state.uri.path == '/login';

      if (!isLoggedIn && !loggingIn) {
        return '/login'; // Se non loggato, vai al login
      }
      if (isLoggedIn && loggingIn) {
        return '/tables'; // Se loggato e provi ad andare al login, vai ai tavoli
      }
      return null;
    },

    routes: [
      // LOGIN CAMERIERE
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          onLoginSuccess: () {
            ref.read(authProvider.notifier).login("1234");
          },
        ),
      ),

      // SALA (Home del cameriere)
      GoRoute(
        path: '/tables',
        builder: (context, state) {
          return TablesView();
        },
      ),

      // MENU (Presa comanda)
      GoRoute(
        path: '/menu/:id',
        builder: (context, state) {
          final tableIdStr = state.pathParameters['id'];
          final tableId = int.tryParse(tableIdStr ?? '') ?? 0;

          final table = ref.read(tablesProvider.notifier).getTableById(tableId);
          return MenuView(
            table: table,
            onSuccess: (newOrders) {
              ref.read(tablesProvider.notifier).addOrdersToTable(tableId, newOrders);
              // Passiamo il nome del tavolo come parametro query per la pagina di successo
              context.go('/success?tableId=$tableId');
            },
          );
        },
      ),

      // SUCCESSO
      GoRoute(
        path: '/success',
        builder: (context, state) {
          final tableIdStr = state.uri.queryParameters['tableId'] ?? '';
          final tableId = int.tryParse(tableIdStr) ?? 0;
          final table = ref.read(tablesProvider.notifier).getTableById(tableId);
          final tableName = table.name;

          // Auto-redirect dopo 2 secondi
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) context.go('/menu/$tableId');
          });

          return SuccessView(tableName: tableName);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});