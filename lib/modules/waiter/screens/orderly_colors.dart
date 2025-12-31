import 'package:flutter/material.dart';
import 'package:orderly/config/themes.dart';

@immutable
class OrderlyColors extends ThemeExtension<OrderlyColors> {
  // Core
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color background;
  final Color surface;
  final Color divider;
  final Color shadow;
  final Color backdrop;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInverse;

  // Semantic States (Main, Container, OnContainer/Content)
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color danger;
  final Color dangerContainer;
  final Color onDangerContainer;

  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;
  
  // Specific Alpha Variants (Const)
  final Color infoSurfaceFaint; // ~10%
  final Color infoSurfaceWeak; // ~25%
  final Color infoSurfaceMedium; // ~30%
  final Color infoSurfaceStrong; // ~50%
  final Color borderExpanded; // ~30% Primary

  final Color hover;

  const OrderlyColors({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.divider,
    required this.shadow,
    required this.backdrop,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.danger,
    required this.dangerContainer,
    required this.onDangerContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.infoSurfaceFaint,
    required this.infoSurfaceWeak,
    required this.infoSurfaceMedium,
    required this.infoSurfaceStrong,
    required this.borderExpanded,
    this.hover = Colors.transparent,
  });

  @override
  OrderlyColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? background,
    Color? surface,
    Color? divider,
    Color? shadow,
    Color? backdrop,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textInverse,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? danger,
    Color? dangerContainer,
    Color? onDangerContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? infoSurfaceFaint,
    Color? infoSurfaceWeak,
    Color? infoSurfaceMedium,
    Color? infoSurfaceStrong,
    Color? borderExpanded,
    Color? hover,
  }) {
    return OrderlyColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      backdrop: backdrop ?? this.backdrop,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textInverse: textInverse ?? this.textInverse,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      onDangerContainer: onDangerContainer ?? this.onDangerContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      infoSurfaceFaint: infoSurfaceFaint ?? this.infoSurfaceFaint,
      infoSurfaceWeak: infoSurfaceWeak ?? this.infoSurfaceWeak,
      infoSurfaceMedium: infoSurfaceMedium ?? this.infoSurfaceMedium,
      infoSurfaceStrong: infoSurfaceStrong ?? this.infoSurfaceStrong,
      borderExpanded: borderExpanded ?? this.borderExpanded,
      hover: hover ?? this.hover,
    );
  }

  @override
  OrderlyColors lerp(ThemeExtension<OrderlyColors>? other, double t) {
    if (other is! OrderlyColors) {
      return this;
    }
    return OrderlyColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      backdrop: Color.lerp(backdrop, other.backdrop, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      onDangerContainer: Color.lerp(onDangerContainer, other.onDangerContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      infoSurfaceFaint: Color.lerp(infoSurfaceFaint, other.infoSurfaceFaint, t)!,
      infoSurfaceWeak: Color.lerp(infoSurfaceWeak, other.infoSurfaceWeak, t)!,
      infoSurfaceMedium: Color.lerp(infoSurfaceMedium, other.infoSurfaceMedium, t)!,
      infoSurfaceStrong: Color.lerp(infoSurfaceStrong, other.infoSurfaceStrong, t)!,
      borderExpanded: Color.lerp(borderExpanded, other.borderExpanded, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
    );
  }

  static const light = OrderlyColors(
    primary: AppColors.cIndigo600,
    onPrimary: AppColors.cWhite,
    secondary: AppColors.cSlate800,
    onSecondary: AppColors.cWhite,
    background: AppColors.cSlate50,
    surface: AppColors.cWhite,
    divider: AppColors.cSlate200,
    shadow: Color(0x0D000000), // 5% Black
    backdrop: AppColors.cBlack,
    textPrimary: AppColors.cSlate900,
    textSecondary: AppColors.cSlate500,
    textTertiary: AppColors.cSlate400,
    textInverse: AppColors.cWhite,
    success: AppColors.cEmerald500,
    successContainer: AppColors.cEmerald100,
    onSuccessContainer: AppColors.cEmerald500,
    danger: AppColors.cRose500,
    dangerContainer: AppColors.cRose50,
    onDangerContainer: AppColors.cRose500,
    warning: AppColors.cAmber700,
    warningContainer: AppColors.cAmber50, // or Orange50
    onWarningContainer: AppColors.cAmber700,
    info: AppColors.cIndigo600,
    infoContainer: AppColors.cIndigo100,
    onInfoContainer: AppColors.cIndigo600,
    infoSurfaceFaint: Color(0x1AE0E7FF), // 10% Indigo100
    infoSurfaceWeak: Color(0x40E0E7FF), // 25% Indigo100
    infoSurfaceMedium: Color(0x4DE0E7FF), // 30% Indigo100
    infoSurfaceStrong: Color(0x80E0E7FF), // 50% Indigo100
    borderExpanded: Color(0x4D4F46E5), // 30% Indigo600
    hover: Colors.transparent,
  );

  static const dark = OrderlyColors(
    primary: AppColors.cIndigo400,
    onPrimary: AppColors.cSlate900,
    secondary: AppColors.cSlate200,
    onSecondary: AppColors.cSlate900,
    background: AppColors.cSlate900,
    surface: AppColors.cSlate800,
    divider: AppColors.cSlate700,
    shadow: Colors.black26,
    backdrop: AppColors.cBlack,
    textPrimary: AppColors.cWhite,
    textSecondary: AppColors.cSlate400,
    textTertiary: AppColors.cSlate500,
    textInverse: AppColors.cSlate900,
    success: AppColors.cEmerald400,
    successContainer: AppColors.cEmerald900,
    onSuccessContainer: AppColors.cEmerald100,
    danger: AppColors.cRose400,
    dangerContainer: Color(0xFF881337),
    onDangerContainer: AppColors.cRose50,
    warning: AppColors.cAmber400,
    warningContainer: Color(0xFF78350F),
    onWarningContainer: AppColors.cAmber50,
    info: AppColors.cIndigo400,
    infoContainer: Color(0xFF312E81),
    onInfoContainer: AppColors.cIndigo100,
    infoSurfaceFaint: Color(0x1A312E81), // 10% Dark Indigo
    infoSurfaceWeak: Color(0x40312E81), // 25% Dark Indigo
    infoSurfaceMedium: Color(0x4D312E81), // 30% Dark Indigo
    infoSurfaceStrong: Color(0x80312E81), // 50% Dark Indigo
    borderExpanded: Color(0x4D818CF8), // 30% Indigo400
    hover: Colors.transparent,
  );
}

extension OrderlyColorsExtension on BuildContext {
  OrderlyColors get colors => Theme.of(this).extension<OrderlyColors>() ?? OrderlyColors.light;
}
