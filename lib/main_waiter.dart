import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:orderly/modules/waiter/config/waiter_router.dart';

import 'l10n/app_localizations.dart';
import 'orderly_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Hive.initFlutter();

  runApp(const ProviderScope(
    child: WaiterAppEntry(),
  ));
}

// L'entry point principale dell'app che utilizza il router.
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
