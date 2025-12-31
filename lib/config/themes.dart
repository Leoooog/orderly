import 'package:flutter/material.dart';

// 1. PALETTE STATICA (I tuoi colori di base rimangono qui)
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
  static const Color cAmber500 = Color(0xFFF59E0B);
  static const Color cTransparent = Colors.transparent;
}

// 2. ESTENSIONE SEMANTICA (Il "Vocabolario" dei colori della tua app)
@immutable
class OrderlyColors extends ThemeExtension<OrderlyColors> {
  final Color tableFreeBg;
  final Color tableFreeBorder;
  final Color tableOccupiedBg;
  final Color tableOccupiedBorder;
  final Color tableTextPrimary;
  final Color tableTextSecondary;
  final Color success;
  final Color danger;
  final Color warning;
  final Color info;
  final Color cardBg;

  const OrderlyColors({
    required this.tableFreeBg,
    required this.tableFreeBorder,
    required this.tableOccupiedBg,
    required this.tableOccupiedBorder,
    required this.tableTextPrimary,
    required this.tableTextSecondary,
    required this.success,
    required this.danger,
    required this.warning,
    required this.info,
    required this.cardBg,
  });

  @override
  OrderlyColors copyWith({
    Color? tableFreeBg,
    Color? tableFreeBorder,
    Color? tableOccupiedBg,
    Color? tableOccupiedBorder,
    Color? tableTextPrimary,
    Color? tableTextSecondary,
    Color? success,
    Color? danger,
    Color? warning,
    Color? info,
    Color? cardBg,
  }) {
    return OrderlyColors(
      tableFreeBg: tableFreeBg ?? this.tableFreeBg,
      tableFreeBorder: tableFreeBorder ?? this.tableFreeBorder,
      tableOccupiedBg: tableOccupiedBg ?? this.tableOccupiedBg,
      tableOccupiedBorder: tableOccupiedBorder ?? this.tableOccupiedBorder,
      tableTextPrimary: tableTextPrimary ?? this.tableTextPrimary,
      tableTextSecondary: tableTextSecondary ?? this.tableTextSecondary,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      cardBg: cardBg ?? this.cardBg,
    );
  }

  @override
  OrderlyColors lerp(ThemeExtension<OrderlyColors>? other, double t) {
    if (other is! OrderlyColors) return this;
    return OrderlyColors(
      tableFreeBg: Color.lerp(tableFreeBg, other.tableFreeBg, t)!,
      tableFreeBorder: Color.lerp(tableFreeBorder, other.tableFreeBorder, t)!,
      tableOccupiedBg: Color.lerp(tableOccupiedBg, other.tableOccupiedBg, t)!,
      tableOccupiedBorder: Color.lerp(tableOccupiedBorder, other.tableOccupiedBorder, t)!,
      tableTextPrimary: Color.lerp(tableTextPrimary, other.tableTextPrimary, t)!,
      tableTextSecondary: Color.lerp(tableTextSecondary, other.tableTextSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
    );
  }
}

// 3. DEFINIZIONE DEI TEMI
class AppTheme {
  // LIGHT THEME
  static final light = ThemeData(
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

    extensions: const [
      OrderlyColors(
        tableFreeBg: AppColors.cEmerald100, // O cWhite nel tuo design
        tableFreeBorder: AppColors.cEmerald500,
        tableOccupiedBg: AppColors.cOrange50,
        tableOccupiedBorder: AppColors.cOrange200,
        tableTextPrimary: AppColors.cSlate800,
        tableTextSecondary: AppColors.cSlate500,
        success: AppColors.cEmerald500,
        danger: AppColors.cRose500,
        warning: AppColors.cAmber700,
        info: AppColors.cIndigo600,
        cardBg: AppColors.cWhite,
      ),
    ],

  );

  // DARK THEME
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.cIndigo600,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E293B), // Slate 800
      onSurface: AppColors.cSlate100,
      primary: AppColors.cIndigo400, // Più luminoso per dark mode
      secondary: AppColors.cSlate200,
    ),
    extensions: const [
      OrderlyColors(
        tableFreeBg: Color(0xFF064E3B), // Emerald 900
        tableFreeBorder: Color(0xFF34D399), // Emerald 400
        tableOccupiedBg: Color(0xFF431407), // Orange 950
        tableOccupiedBorder: Color(0xFFFB923C), // Orange 400
        tableTextPrimary: AppColors.cSlate100,
        tableTextSecondary: AppColors.cSlate400,
        success: Color(0xFF34D399), // Emerald 400
        danger: Color(0xFFFB7185), // Rose 400
        warning: Color(0xFFFBBF24), // Amber 400
        info: Color(0xFF818CF8), // Indigo 400
        cardBg: Color(0xFF1E293B), // Slate 800
      ),
    ],
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: AppColors.cWhite,
      elevation: 0,
    ),
  );
}