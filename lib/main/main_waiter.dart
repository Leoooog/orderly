import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/modules/waiter/providers/waiter_router_provider.dart';

import '../orderly_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: WaiterAppEntry(),
    ),
  );
}

// Piccolo widget wrapper per leggere il provider del router
// (Necessario perché non puoi leggere un provider prima di essere dentro un ProviderScope)
class WaiterAppEntry extends ConsumerWidget {
  const WaiterAppEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(waiterRouterProvider);

    return OrderlyApp(
      router: router,
      title: 'Orderly - Sala',
    );
  }
}