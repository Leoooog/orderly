import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Importa go_router
import 'config/themes.dart';
import 'l10n/app_localizations.dart';

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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.cWhite,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp.router( // .router invece di costruttore normale
      onGenerateTitle: onGenerateTitle,
      debugShowCheckedModeBanner: false,

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

      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.cSlate50,
        primaryColor: AppColors.cIndigo600,
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.cIndigo600,
          surface: AppColors.cWhite,
          primary: AppColors.cIndigo600,
          secondary: AppColors.cSlate800,
          error: AppColors.cRose500,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cWhite,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.cSlate800),
          titleTextStyle: TextStyle(
            color: AppColors.cSlate900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cIndigo600,
            foregroundColor: AppColors.cWhite,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cSlate50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: AppColors.cSlate400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}