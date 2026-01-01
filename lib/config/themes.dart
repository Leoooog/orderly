import 'package:flutter/material.dart';
import 'package:orderly/config/orderly_colors.dart';

// 1. PALETTE STATICA
class AppColors {
  static const Color cIndigo600 = Color(0xFF4F46E5);
  static const Color cIndigo400 = Color(0xFF818CF8); // Variante per dark mode
  static const Color cIndigo100 = Color(0xFFE0E7FF);

  static const Color cSlate900 = Color(0xFF0F172A);
  static const Color cSlate800 = Color(0xFF1E293B);
  static const Color cSlate700 = Color(0xFF334155);
  static const Color cSlate600 = Color(0xFF475569);
  static const Color cSlate500 = Color(0xFF64748B);
  static const Color cSlate400 = Color(0xFF94A3B8);
  static const Color cSlate300 = Color(0xFFCBD5E1);
  static const Color cSlate200 = Color(0xFFE2E8F0);
  static const Color cSlate100 = Color(0xFFF1F5F9);
  static const Color cSlate50 = Color(0xFFF8FAFC);

  static const Color cWhite = Colors.white;
  static const Color cBlack = Colors.black;

  static const Color cEmerald500 = Color(0xFF10B981);
  static const Color cEmerald100 = Color(0xFFD1FAE5);
  static const Color cRose500 = Color(0xFFF43F5E);
  static const Color cRose50 = Color(0xFFFFF1F2);
  static const Color cOrange50 = Color(0xFFFFF7ED);
  static const Color cOrange200 = Color(0xFFFED7AA);
  static const Color cOrange700 = Color(0xFFC2410C);
  static const Color cAmber100 = Color(0xFFFEF3C7);
  static const Color cAmber50 = Color(0xFFFFFBEB);
  static const Color cAmber700 = Color(0xFFB45309);

  // Colori extra specifici per Dark Mode (Hardcoded per precisione)
  static const Color cEmerald900 = Color(0xFF064E3B);
  static const Color cEmerald400 = Color(0xFF34D399);
  static const Color cOrange950 = Color(0xFF431407);
  static const Color cOrange400 = Color(0xFFFB923C);
  static const Color cRose400 = Color(0xFFFB7185);
  static const Color cAmber400 = Color(0xFFFBBF24);
  static const Color cTransparent = Colors.transparent;
  static const Color cAmber500 = Color(0xFFF59E0B);
}

// 3. DEFINIZIONE DEI TEMI
class AppTheme {
  // --- LIGHT THEME ---
  static final light = ThemeData(
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.cSlate50,
    primaryColor: AppColors.cIndigo600,
    useMaterial3: true,
    brightness: Brightness.light,

    extensions: [
      OrderlyColors.light,
    ],

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.cIndigo600,
      brightness: Brightness.light,
      surface: AppColors.cWhite,
      primary: AppColors.cIndigo600,
      secondary: AppColors.cSlate800,
      error: AppColors.cRose500,
      onSurface: AppColors.cSlate900,
    ),

    appBarTheme: AppBarTheme(
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

  );

  // --- DARK THEME ---
  static final dark = ThemeData(
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.cSlate900, // Sfondo scuro
    primaryColor: AppColors.cIndigo400, // Colore primario più chiaro per contrasto
    useMaterial3: true,
    brightness: Brightness.dark,

    extensions: [
      OrderlyColors.dark,
    ],

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.cIndigo600,
      brightness: Brightness.dark,
      surface: AppColors.cSlate800, // Card scure
      primary: AppColors.cIndigo400,
      secondary: AppColors.cSlate200,
      error: AppColors.cRose400, // Rosso pastello
      onSurface: AppColors.cSlate100, // Testo chiaro
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cSlate800,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.cSlate100),
      titleTextStyle: TextStyle(
        color: AppColors.cSlate100,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cIndigo400,
        foregroundColor: AppColors.cSlate900, // Testo scuro su bottone chiaro
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cSlate800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: AppColors.cSlate400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

  );
}
