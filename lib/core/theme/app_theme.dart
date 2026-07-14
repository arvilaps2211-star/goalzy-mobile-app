import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final g = isDark ? GoalzyColors.dark : GoalzyColors.light;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: g.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: g.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: g.surface,
        onSurface: g.textPrimary,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      dividerColor: g.border,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );

    final textTheme = _textTheme(g);

    return base.copyWith(
      extensions: [g],
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: g.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: g.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          side: BorderSide(color: g.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: g.chipFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: g.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: g.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: g.primary, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: g.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: g.chipFill,
        selectedColor: g.primary.withValues(alpha: 0.12),
        labelStyle: textTheme.labelMedium!,
        side: BorderSide(color: g.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: g.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: g.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: g.border),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: g.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static TextTheme _textTheme(GoalzyColors g) {
    // Plus Jakarta Sans as SF Pro Display alternative
    return GoogleFonts.plusJakartaSansTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1.2, color: g.textPrimary, height: 1.1),
        displayMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: g.textPrimary, height: 1.15),
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: g.textPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: g.textPrimary),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: g.textPrimary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: g.textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: g.textPrimary),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: g.textPrimary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: g.textPrimary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: g.textSecondary, height: 1.45),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: g.textMuted),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: g.textPrimary),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: g.textSecondary),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: g.textMuted),
      ),
    );
  }
}
