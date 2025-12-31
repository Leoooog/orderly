import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Importa go_router
import 'config/themes.dart';
import 'l10n/app_localizations.dart';
import 'modules/waiter/providers/locale_provider.dart';
import 'modules/waiter/providers/theme_provider.dart';

class OrderlyApp extends ConsumerWidget {
  // Non serve più passare "home", passiamo il routerConfig
  final GoRouter router;
  final String Function(BuildContext) onGenerateTitle;

  const OrderlyApp({
    super.key,
    required this.router, // Obbligatorio
    required this.onGenerateTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.cWhite,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));


    return MaterialApp.router( // .router invece di costruttore normale
      onGenerateTitle: onGenerateTitle,
      debugShowCheckedModeBanner: false,

      themeMode: themeMode,
      darkTheme: AppTheme.dark,
      theme: AppTheme.light,


      // Colleghiamo il router passato
      routerConfig: router,
      builder: (context, child) {
        return Scaffold(
          // Sfondo scuro per il desktop ("fuori" dal telefono)
          backgroundColor: AppColors.cSlate900,
          body: Center(
            child: Container(
              // Forziamo la larghezza massima a quella di un tablet/telefono grande
              constraints: const BoxConstraints(maxWidth: 450),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  color: AppColors.cSlate50, // Sfondo dell'app vera e propria
                  boxShadow: [
                    BoxShadow(color: AppColors.cBlack.withValues(alpha: 0.3), blurRadius: 20)
                  ]
              ),
              // 'child' qui è il Navigator gestito da GoRouter
              child: child,
            ),
          ),
        );
      },

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('it'), // Italiano (Default)
        Locale('en'), // Inglese
      ],
      locale: currentLocale,
    );
  }
}