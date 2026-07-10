import 'package:flutter/material.dart';

/// Semantic color tokens. Prefer [GoalzyColors.of] in widgets for theme-aware colors.
abstract final class AppColors {
  // Light palette
  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightText = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Dark palette
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF171923);
  static const Color darkBorder = Color(0xFF252836);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // Brand (shared)
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF7C8CFF);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color danger = Color(0xFFFF453A);

  // Legacy aliases (light defaults — screens using ThemeExtension migrate gradually)
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color textPrimary = lightText;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color glassBorder = lightBorder;
  static const Color glassFill = Color(0xFFF3F4F6);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Flat background — no heavy gradients.
  /// Flat page background — no heavy gradients.
  static BoxDecoration pageDecoration(BuildContext context) =>
      BoxDecoration(color: GoalzyColors.of(context).background);

  /// Legacy compat — flat gradient (same color twice).
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [lightBackground, lightBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

@immutable
class GoalzyColors extends ThemeExtension<GoalzyColors> {
  const GoalzyColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.shadow,
    required this.chipFill,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color shadow;
  final Color chipFill;

  static const light = GoalzyColors(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceElevated: Color(0xFFFFFFFF),
    border: AppColors.lightBorder,
    textPrimary: AppColors.lightText,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: Color(0xFF9CA3AF),
    primary: AppColors.primary,
    shadow: Color(0x14111827),
    chipFill: Color(0xFFF3F4F6),
  );

  static const dark = GoalzyColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceElevated: Color(0xFF1E2130),
    border: AppColors.darkBorder,
    textPrimary: AppColors.darkText,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: Color(0xFF6B7280),
    primary: AppColors.primaryDark,
    shadow: Color(0x40000000),
    chipFill: Color(0xFF252836),
  );

  static GoalzyColors of(BuildContext context) =>
      Theme.of(context).extension<GoalzyColors>() ?? light;

  @override
  GoalzyColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primary,
    Color? shadow,
    Color? chipFill,
  }) {
    return GoalzyColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primary: primary ?? this.primary,
      shadow: shadow ?? this.shadow,
      chipFill: chipFill ?? this.chipFill,
    );
  }

  @override
  GoalzyColors lerp(ThemeExtension<GoalzyColors>? other, double t) {
    if (other is! GoalzyColors) return this;
    return GoalzyColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      chipFill: Color.lerp(chipFill, other.chipFill, t)!,
    );
  }
}

extension GoalzyThemeContext on BuildContext {
  GoalzyColors get g => GoalzyColors.of(this);
}
