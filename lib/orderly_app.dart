import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/themes.dart';

class OrderlyApp extends StatelessWidget {
  final Widget home; // Widget iniziale iniettato dal main
  final String title; // NUOVO: Titolo specifico per l'app (es. "Camerieri")

  const OrderlyApp({
    super.key,
    required this.home,
    this.title = 'Orderly Pocket', // Valore di default
  });

  @override
  Widget build(BuildContext context) {
    // Impostiamo lo stile della barra di stato del sistema per coerenza
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.cWhite,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      // Usiamo il titolo passato come parametro
      title: title,
      debugShowCheckedModeBanner: false,

      // Configurazione del Tema condivisa
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

      // Qui carichiamo il modulo specifico
      home: home,
    );
  }
}