import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:orderly/shared/widgets/loading_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_client.dart';
import 'core/config/user_context.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeSupabase();
  runApp(const OrderlyApp());
}

class OrderlyApp extends StatefulWidget {
  const OrderlyApp({super.key});

  @override
  State<OrderlyApp> createState() => _OrderlyAppState();
}

class _OrderlyAppState extends State<OrderlyApp> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();

    // ascolta cambiamenti auth (login/logout)
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        _bootstrap();
      }

      if (event.event == AuthChangeEvent.signedOut) {
        setState(() {
          _loading = false;
          UserContext.clear();
        });
      }
    });
  }

  /// Carica UserContext da DB (sia admin che staff)
  Future<void> _bootstrap() async {
    setState(() => _loading = true);

    final session = supabase.auth.currentSession;
    if (session == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final userContext = await _loadUserContext(session.user.id);
    setState(() {
      _loading = false;
      UserContext.instance = userContext;
    });
  }

  /// Legge la riga staff (admin incluso) dal DB
  Future<UserContext?> _loadUserContext(String authUserId) async {
    final supabase = Supabase.instance.client;

    final res = await supabase
        .from('staff')
        .select('id, name, role, restaurant_id, restaurants(name)')
        .eq('auth_user_id', authUserId)
        .maybeSingle();

    if (res == null) return null;

    return UserContext(
      authUserId: authUserId,
      staffId: res['id'],
      staffName: res['name'],
      role: res['role'] == 'admin' ? 'admin' : 'staff',
      staffRole: res['role'] != 'admin' ? res['role'] : null,
      restaurantId: res['restaurant_id'],
      restaurantName: res['restaurants']?['name'],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(home: const LoadingWidget(), scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: const {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),);
    }

    return AppRouter();
  }
}
