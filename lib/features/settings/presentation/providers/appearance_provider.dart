import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';

/// User-facing appearance customization, layered ON TOP of the existing
/// theme system rather than replacing any of it.
///
/// Scope, deliberately: changing these only affects (1) the app's global
/// accent — used by neutral/non-module-scoped chrome (e.g. default
/// buttons, Notifications, the pre-auth Splash/Login screens) — and (2)
/// the font used everywhere. It does NOT touch any of the 10 per-module
/// identities defined in core/theme/module_theme.dart (Dashboard stays
/// lavender, Tasks stays blue, Habits stays green, etc.) — those are a
/// deliberate, brief-specified design system and overriding them with a
/// single user accent would undermine the whole point of having them.
/// It also never touches AppThemeMode/SettingsState/settingsProvider
/// (light/dark/system mode) in settings_screen.dart, which remains
/// completely separate, pre-existing, live business logic.
enum AccentPreset { violet, blue, green, orange, pink, mono }

enum AppFontChoice { system, jakarta, poppins, inter, nunito, playfair }

class AppearancePreset {
  const AppearancePreset({required this.label, required this.accent, required this.font});
  final String label;
  final AccentPreset accent;
  final AppFontChoice font;
}

/// Ready-made accent+font combinations, shown as one-tap presets in
/// Settings. "Default" intentionally matches the app's original,
/// pre-customization appearance exactly.
const appearancePresets = [
  AppearancePreset(label: 'Default', accent: AccentPreset.violet, font: AppFontChoice.jakarta),
  AppearancePreset(label: 'Ocean', accent: AccentPreset.blue, font: AppFontChoice.inter),
  AppearancePreset(label: 'Forest', accent: AccentPreset.green, font: AppFontChoice.nunito),
  AppearancePreset(label: 'Sunset', accent: AccentPreset.orange, font: AppFontChoice.poppins),
  AppearancePreset(label: 'Blossom', accent: AccentPreset.pink, font: AppFontChoice.jakarta),
  AppearancePreset(label: 'Mono', accent: AccentPreset.mono, font: AppFontChoice.playfair),
];

/// [AccentPreset.violet] resolves to the app's original static brand
/// colors exactly (AppColors.primary / primaryDark) so that the default
/// appearance — before a user ever touches this screen — is unchanged,
/// bit-for-bit, from before this feature existed.
Color accentColorFor(AccentPreset preset, Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return switch (preset) {
    AccentPreset.violet => isDark ? AppColors.primaryDark : AppColors.primary,
    AccentPreset.blue => isDark ? const Color(0xFF6FB8FF) : const Color(0xFF2F82FF),
    AccentPreset.green => isDark ? const Color(0xFF64D488) : const Color(0xFF23A85B),
    AccentPreset.orange => isDark ? const Color(0xFFFFB876) : const Color(0xFFE8862E),
    AccentPreset.pink => isDark ? const Color(0xFFFF8FB8) : const Color(0xFFE85D91),
    AccentPreset.mono => isDark ? const Color(0xFFE8E8EA) : const Color(0xFF2C2C2E),
  };
}

String accentLabel(AccentPreset preset) => switch (preset) {
      AccentPreset.violet => 'Violet',
      AccentPreset.blue => 'Ocean Blue',
      AccentPreset.green => 'Forest Green',
      AccentPreset.orange => 'Sunset Orange',
      AccentPreset.pink => 'Blossom Pink',
      AccentPreset.mono => 'Monochrome',
    };

String fontLabel(AppFontChoice font) => switch (font) {
      AppFontChoice.system => 'System Default',
      AppFontChoice.jakarta => 'Plus Jakarta Sans',
      AppFontChoice.poppins => 'Poppins',
      AppFontChoice.inter => 'Inter',
      AppFontChoice.nunito => 'Nunito',
      AppFontChoice.playfair => 'Playfair Display',
    };

/// Applies the chosen font's GoogleFonts wrapper to a base [TextTheme],
/// preserving every size/weight/color already set on it — same pattern
/// already used for the app's original default font in app_theme.dart.
/// [AppFontChoice.system] deliberately returns [base] unchanged (no
/// network font fetch), so "System Default" always renders immediately
/// even offline.
TextTheme applyFont(AppFontChoice font, TextTheme base) => switch (font) {
      AppFontChoice.system => base,
      AppFontChoice.jakarta => GoogleFonts.plusJakartaSansTextTheme(base),
      AppFontChoice.poppins => GoogleFonts.poppinsTextTheme(base),
      AppFontChoice.inter => GoogleFonts.interTextTheme(base),
      AppFontChoice.nunito => GoogleFonts.nunitoTextTheme(base),
      AppFontChoice.playfair => GoogleFonts.playfairDisplayTextTheme(base),
    };

class AppearanceState {
  const AppearanceState({this.accent = AccentPreset.violet, this.font = AppFontChoice.jakarta});
  final AccentPreset accent;
  final AppFontChoice font;
}

class AppearanceNotifier extends StateNotifier<AppearanceState> {
  AppearanceNotifier() : super(const AppearanceState()) {
    _restore();
  }

  static const _accentKey = 'appearance_accent_index';
  static const _fontKey = 'appearance_font_index';

  /// Loads any previously-saved choice. Runs asynchronously after the
  /// initial (default) state is already showing, so the UI never blocks
  /// on this — if a saved value exists, the state updates once it's read,
  /// which (same as every other change here) rebuilds reactively via
  /// Riverpod with no restart needed.
  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final accentIndex = prefs.getInt(_accentKey);
    final fontIndex = prefs.getInt(_fontKey);
    final accent = (accentIndex != null && accentIndex >= 0 && accentIndex < AccentPreset.values.length)
        ? AccentPreset.values[accentIndex]
        : state.accent;
    final font = (fontIndex != null && fontIndex >= 0 && fontIndex < AppFontChoice.values.length)
        ? AppFontChoice.values[fontIndex]
        : state.font;
    if (accent != state.accent || font != state.font) {
      state = AppearanceState(accent: accent, font: font);
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentKey, state.accent.index);
    await prefs.setInt(_fontKey, state.font.index);
  }

  void setAccent(AccentPreset accent) {
    state = AppearanceState(accent: accent, font: state.font);
    _persist();
  }

  void setFont(AppFontChoice font) {
    state = AppearanceState(accent: state.accent, font: font);
    _persist();
  }

  void applyPreset(AppearancePreset preset) {
    state = AppearanceState(accent: preset.accent, font: preset.font);
    _persist();
  }

  void reset() {
    state = const AppearanceState();
    _persist();
  }
}

final appearanceProvider = StateNotifierProvider<AppearanceNotifier, AppearanceState>((ref) {
  return AppearanceNotifier();
});
