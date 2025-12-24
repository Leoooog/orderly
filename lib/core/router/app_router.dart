import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/features/auth/login/email_login_page.dart';
import 'package:orderly/features/auth/login/qr_login_page.dart';

import '../../features/auth/login/login_page.dart';
import '../../features/admin/admin_home.dart';
import '../../features/menu/menu_page.dart';
import '../../features/staff/kitchen/kitchen_page.dart';
import '../../features/staff/orders/order_page.dart';
import '../../features/staff/orders/orders_page.dart';
import '../../features/staff/staff_home_page.dart';
import '../config/user_context.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        UserContext? user = UserContext.instance;
        final isLoggedIn = user != null;
        final location = state.uri.path;

        // MENU PUBBLICO
        if (location.startsWith('/menu')) return null;

        // NON LOGGATO → consenti solo login
        if (!isLoggedIn) {
          if (location == '/login' ||
              location == '/admin_login' ||
              location == '/staff_login') {
            return null;
          }
          return '/login';
        }

        // LOGGATO → blocca login
        if (location == '/login' ||
            location == '/admin_login' ||
            location == '/staff_login') {
          if (user.role == 'admin') return '/admin';
          if (user.role == 'staff') return '/staff';
        }

        // STAFF → no admin
        if (user.role == 'staff' && location.startsWith('/admin')) {
          return '/staff';
        }

        // ADMIN → no staff
        if (user.role == 'admin' && location.startsWith('/staff')) {
          return '/admin';
        }

        return null;
      },
      routes: [
        /// LOGIN (admin + staff)
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),

        /// ADMIN HOME (NavigationRail interna)
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminHomePage(),
        ),

        /// STAFF HOME
        GoRoute(
          path: '/staff',
          builder: (context, state) => const StaffHomePage(),
        ),

        /// ORDERS (staff waiter)
        GoRoute(
          path: '/staff/orders',
          builder: (context, state) => const OrdersPage(),
        ),

        /// ORDERS NEW (staff waiter)
        /// path: /staff/orders/new
        /// handled inside OrdersPage
        GoRoute(
          path: '/staff/orders/new',
          builder: (context, state) => const OrderPage(),
        ),

        GoRoute(path: '/staff/orders/:orderId', builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId']!);
          return OrderPage(orderId: orderId); // Fetch order by ID if needed
        }),

        /// KITCHEN (staff kitchen)
        GoRoute(
          path: '/staff/kitchen',
          builder: (context, state) => const KitchenPage(),
        ),

        GoRoute(
          path: '/admin_login',
          builder: (context, state) => const EmailLoginPage(),
        ),

        GoRoute(
          path: '/staff_login',
          builder: (context, state) => const QRPinLoginPage(),
        ),

        /// MENU PUBBLICO CLIENTI
        GoRoute(
          path: '/menu',
          builder: (context, state) {
            final restaurantId = state.uri.queryParameters['restaurant'];
            final tableId = state.uri.queryParameters['table'];

            if (restaurantId == null || tableId == null) {
              return const Scaffold(
                body: Center(
                  child: Text('Ristorante o tavolo non valido'),
                ),
              );
            }

            return MenuPage(
              restaurantId: restaurantId,
              tableId: tableId,
            );
          },
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
