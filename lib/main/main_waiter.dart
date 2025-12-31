import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:orderly/modules/waiter/providers/waiter_router_provider.dart';

import '../data/hive_keys.dart';
import '../l10n/app_localizations.dart';
import '../orderly_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Hive.initFlutter();

  await Hive.openBox(kTablesBox);
  await Hive.openBox(kVoidsBox);
  await Hive.openBox(kSettingsBox);

  runApp(const ProviderScope(
    child: WaiterAppEntry(),
  ));
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
      onGenerateTitle: (context) => AppLocalizations.of(context)!.waiterAppName,
    );
  }
}
