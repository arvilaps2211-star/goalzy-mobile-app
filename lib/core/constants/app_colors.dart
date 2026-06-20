import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF6D5DF6);
  static const Color secondary = Color(0xFF00D4FF);
  static const Color background = Color(0xFF0B1020);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFF1A2235);
  static const Color success = Color(0xFF00E396);
  static const Color warning = Color(0xFFFFB547);
  static const Color danger = Color(0xFFFF6B81);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassFill = Color(0x1AFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF111827), Color(0xFF0B1020)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
