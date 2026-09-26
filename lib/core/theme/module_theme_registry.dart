import 'package:flutter/material.dart';
import 'module_theme.dart';

/// Static registry of every module's light + dark [ModuleThemeData].
///
/// This is the single source of truth for GOALZY's context-aware design
/// language. Colors follow the module palette defined in the design brief;
/// where the brief only specified a dark *background* (Dashboard, Tasks,
/// Habits, Analytics, AI, Calendar, Focus), the matching primary/accent/card
/// tones below were extrapolated to keep each module's identity legible in
/// dark mode. Goals, Profile, and Settings had no dark spec at all, so their
/// dark palettes are fully extrapolated from their light identity using the
/// same formula (desaturated near-black surface, brightened primary/accent
/// for contrast).
///
/// Adding a new module later: add one enum value in `module_theme.dart`,
/// then one light/dark pair here. No screen ever needs to change.
abstract final class GoalzyModuleTheme {
  static ModuleThemeData resolve(GoalzyModule module, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (module) {
      case GoalzyModule.dashboard:
        return isDark ? _dashboardDark : _dashboardLight;
      case GoalzyModule.goals:
        return isDark ? _goalsDark : _goalsLight;
      case GoalzyModule.tasks:
        return isDark ? _tasksDark : _tasksLight;
      case GoalzyModule.habits:
        return isDark ? _habitsDark : _habitsLight;
      case GoalzyModule.calendar:
        return isDark ? _calendarDark : _calendarLight;
      case GoalzyModule.analytics:
        return isDark ? _analyticsDark : _analyticsLight;
      case GoalzyModule.aiAssistant:
        return isDark ? _aiDark : _aiLight;
      case GoalzyModule.focus:
        return isDark ? _focusDark : _focusLight;
      case GoalzyModule.profile:
        return isDark ? _profileDark : _profileLight;
      case GoalzyModule.settings:
        return isDark ? _settingsDark : _settingsLight;
    }
  }

  // ---------------------------------------------------------------------
  // Shared motion presets — reused across modules with similar emotional
  // pacing so the animation "grammar" stays consistent while the pacing
  // itself differs per module.
  // ---------------------------------------------------------------------

  static const _calm = ModuleMotion(
    entranceDuration: Duration(milliseconds: 420),
    entranceCurve: Curves.easeOutCubic,
    microDuration: Duration(milliseconds: 200),
    microCurve: Curves.easeOut,
    emphasisDuration: Duration(milliseconds: 450),
    emphasisCurve: Curves.easeOutCubic,
  );

  static const _fast = ModuleMotion(
    entranceDuration: Duration(milliseconds: 260),
    entranceCurve: Curves.easeOut,
    microDuration: Duration(milliseconds: 150),
    microCurve: Curves.easeOutBack,
    emphasisDuration: Duration(milliseconds: 320),
    emphasisCurve: Curves.easeOutBack,
  );

  static const _growth = ModuleMotion(
    entranceDuration: Duration(milliseconds: 500),
    entranceCurve: Curves.easeOutQuint,
    microDuration: Duration(milliseconds: 260),
    microCurve: Curves.easeOutCubic,
    emphasisDuration: Duration(milliseconds: 550),
    emphasisCurve: Curves.easeOutBack,
  );

  static const _organic = ModuleMotion(
    entranceDuration: Duration(milliseconds: 450),
    entranceCurve: Curves.easeOutCubic,
    microDuration: Duration(milliseconds: 320),
    microCurve: Curves.easeOutBack,
    emphasisDuration: Duration(milliseconds: 600),
    emphasisCurve: Curves.elasticOut,
    ambientLoopDuration: Duration(milliseconds: 2200),
    ambientLoopCurve: Curves.easeInOut,
  );

  static const _reveal = ModuleMotion(
    entranceDuration: Duration(milliseconds: 700),
    entranceCurve: Curves.easeOutExpo,
    microDuration: Duration(milliseconds: 240),
    microCurve: Curves.easeOut,
    emphasisDuration: Duration(milliseconds: 500),
    emphasisCurve: Curves.easeOutCubic,
  );

  static const _ambientGlow = ModuleMotion(
    entranceDuration: Duration(milliseconds: 350),
    entranceCurve: Curves.easeOut,
    microDuration: Duration(milliseconds: 180),
    microCurve: Curves.easeOut,
    emphasisDuration: Duration(milliseconds: 400),
    emphasisCurve: Curves.easeOutCubic,
    ambientLoopDuration: Duration(milliseconds: 1600),
    ambientLoopCurve: Curves.easeInOut,
  );

  static const _breathing = ModuleMotion(
    entranceDuration: Duration(milliseconds: 600),
    entranceCurve: Curves.easeInOutCubic,
    microDuration: Duration(milliseconds: 300),
    microCurve: Curves.easeInOut,
    emphasisDuration: Duration(milliseconds: 500),
    emphasisCurve: Curves.easeOutCubic,
    ambientLoopDuration: Duration(milliseconds: 4000),
    ambientLoopCurve: Curves.easeInOut,
  );

  static const _gentle = ModuleMotion(
    entranceDuration: Duration(milliseconds: 250),
    entranceCurve: Curves.easeOut,
    microDuration: Duration(milliseconds: 150),
    microCurve: Curves.easeOut,
    emphasisDuration: Duration(milliseconds: 350),
    emphasisCurve: Curves.easeOutCubic,
  );

  // ---------------------------------------------------------------------
  // Dashboard — calm, motivating, morning energy.
  // ---------------------------------------------------------------------
  static const _dashboardLight = ModuleThemeData(
    module: GoalzyModule.dashboard,
    primary: Color(0xFF7C6BFF),
    accent: Color(0xFFA992FF),
    surface: Color(0xFFF7F5FF),
    background: Color(0xFFF7F5FF),
    cardColor: Colors.white,
    borderColor: Color(0xFFE9E4FF),
    decoration: ModuleDecorationStyle.blurredCircles,
    cardRadius: 28,
    filledIcons: true,
    motion: _calm,
  );

  static const _dashboardDark = ModuleThemeData(
    module: GoalzyModule.dashboard,
    primary: Color(0xFF9B8CFF),
    accent: Color(0xFFC3B8FF),
    surface: Color(0xFF12121A),
    background: Color(0xFF12121A),
    cardColor: Color(0xFF1B1B26),
    borderColor: Color(0xFF272736),
    decoration: ModuleDecorationStyle.blurredCircles,
    cardRadius: 28,
    filledIcons: true,
    motion: _calm,
  );

  // ---------------------------------------------------------------------
  // Goals — purpose, direction, achievement.
  // ---------------------------------------------------------------------
  static const _goalsLight = ModuleThemeData(
    module: GoalzyModule.goals,
    primary: Color(0xFF5B4CF6),
    accent: Color(0xFF8C7CFF),
    surface: Color(0xFFF5F4FF),
    background: Color(0xFFF5F4FF),
    cardColor: Colors.white,
    borderColor: Color(0xFFE6E3FF),
    decoration: ModuleDecorationStyle.abstractWaves,
    cardRadius: 28,
    filledIcons: true,
    motion: _growth,
  );

  static const _goalsDark = ModuleThemeData(
    module: GoalzyModule.goals,
    primary: Color(0xFF8C7CFF),
    accent: Color(0xFFB0A4FF),
    surface: Color(0xFF14121F),
    background: Color(0xFF14121F),
    cardColor: Color(0xFF1D1A2C),
    borderColor: Color(0xFF29253C),
    decoration: ModuleDecorationStyle.abstractWaves,
    cardRadius: 28,
    filledIcons: true,
    motion: _growth,
  );

  // ---------------------------------------------------------------------
  // Tasks — action, productivity, speed.
  // ---------------------------------------------------------------------
  static const _tasksLight = ModuleThemeData(
    module: GoalzyModule.tasks,
    primary: Color(0xFF55A8FF),
    accent: Color(0xFF84C7FF),
    surface: Color(0xFFF4FAFF),
    background: Color(0xFFF4FAFF),
    cardColor: Colors.white,
    borderColor: Color(0xFFDDEEFF),
    decoration: ModuleDecorationStyle.dottedGrid,
    cardRadius: 22,
    filledIcons: false,
    motion: _fast,
  );

  static const _tasksDark = ModuleThemeData(
    module: GoalzyModule.tasks,
    primary: Color(0xFF6FB8FF),
    accent: Color(0xFF9DD3FF),
    surface: Color(0xFF111824),
    background: Color(0xFF111824),
    cardColor: Color(0xFF19212F),
    borderColor: Color(0xFF232C3D),
    decoration: ModuleDecorationStyle.dottedGrid,
    cardRadius: 22,
    filledIcons: false,
    motion: _fast,
  );

  // ---------------------------------------------------------------------
  // Habits — growth, consistency, health.
  // ---------------------------------------------------------------------
  static const _habitsLight = ModuleThemeData(
    module: GoalzyModule.habits,
    primary: Color(0xFF49C16D),
    accent: Color(0xFF8BE39D),
    surface: Color(0xFFF4FFF6),
    background: Color(0xFFF4FFF6),
    cardColor: Colors.white,
    borderColor: Color(0xFFDDF7E2),
    decoration: ModuleDecorationStyle.organicBlobs,
    cardRadius: 28,
    filledIcons: true,
    motion: _organic,
  );

  static const _habitsDark = ModuleThemeData(
    module: GoalzyModule.habits,
    primary: Color(0xFF64D488),
    accent: Color(0xFF9DEEB0),
    surface: Color(0xFF111A14),
    background: Color(0xFF111A14),
    cardColor: Color(0xFF19241C),
    borderColor: Color(0xFF243026),
    decoration: ModuleDecorationStyle.organicBlobs,
    cardRadius: 28,
    filledIcons: true,
    motion: _organic,
  );

  // ---------------------------------------------------------------------
  // Calendar — planning, organization.
  // ---------------------------------------------------------------------
  static const _calendarLight = ModuleThemeData(
    module: GoalzyModule.calendar,
    primary: Color(0xFFFFAA5B),
    accent: Color(0xFFFFD18B),
    surface: Color(0xFFFFF8F1),
    background: Color(0xFFFFF8F1),
    cardColor: Colors.white,
    borderColor: Color(0xFFFFE8D1),
    decoration: ModuleDecorationStyle.timelineAccents,
    cardRadius: 24,
    filledIcons: false,
    motion: _calm,
  );

  static const _calendarDark = ModuleThemeData(
    module: GoalzyModule.calendar,
    primary: Color(0xFFFFB876),
    accent: Color(0xFFFFDBA3),
    surface: Color(0xFF1D1712),
    background: Color(0xFF1D1712),
    cardColor: Color(0xFF27201A),
    borderColor: Color(0xFF332A22),
    decoration: ModuleDecorationStyle.timelineAccents,
    cardRadius: 24,
    filledIcons: false,
    motion: _calm,
  );

  // ---------------------------------------------------------------------
  // Analytics — insight, intelligence, reflection.
  // ---------------------------------------------------------------------
  static const _analyticsLight = ModuleThemeData(
    module: GoalzyModule.analytics,
    primary: Color(0xFFFF7BA8),
    accent: Color(0xFFFFB6D0),
    surface: Color(0xFFFFF4F8),
    background: Color(0xFFFFF4F8),
    cardColor: Colors.white,
    borderColor: Color(0xFFFFDEE9),
    decoration: ModuleDecorationStyle.graphLines,
    cardRadius: 24,
    filledIcons: false,
    motion: _reveal,
  );

  static const _analyticsDark = ModuleThemeData(
    module: GoalzyModule.analytics,
    primary: Color(0xFFFF8FB8),
    accent: Color(0xFFFFC2D8),
    surface: Color(0xFF1B1418),
    background: Color(0xFF1B1418),
    cardColor: Color(0xFF251C21),
    borderColor: Color(0xFF31262C),
    decoration: ModuleDecorationStyle.graphLines,
    cardRadius: 24,
    filledIcons: false,
    motion: _reveal,
  );

  // ---------------------------------------------------------------------
  // AI Assistant — smart, friendly, calm. A life coach, not a chatbot.
  // ---------------------------------------------------------------------
  static const _aiLight = ModuleThemeData(
    module: GoalzyModule.aiAssistant,
    primary: Color(0xFF4FD6FF),
    accent: Color(0xFF9DEBFF),
    surface: Color(0xFFF3FCFF),
    background: Color(0xFFF3FCFF),
    cardColor: Colors.white,
    borderColor: Color(0xFFD9F4FF),
    decoration: ModuleDecorationStyle.neuralParticles,
    cardRadius: 28,
    filledIcons: true,
    motion: _ambientGlow,
  );

  static const _aiDark = ModuleThemeData(
    module: GoalzyModule.aiAssistant,
    primary: Color(0xFF6BE0FF),
    accent: Color(0xFFAEF0FF),
    surface: Color(0xFF101A20),
    background: Color(0xFF101A20),
    cardColor: Color(0xFF17232A),
    borderColor: Color(0xFF203039),
    decoration: ModuleDecorationStyle.neuralParticles,
    cardRadius: 28,
    filledIcons: true,
    motion: _ambientGlow,
  );

  // ---------------------------------------------------------------------
  // Focus Mode — deep work, silence, presence.
  // ---------------------------------------------------------------------
  static const _focusLight = ModuleThemeData(
    module: GoalzyModule.focus,
    primary: Color(0xFF875BFF),
    accent: Color(0xFFB39BFF),
    surface: Color(0xFFF7F3FF),
    background: Color(0xFFF7F3FF),
    cardColor: Colors.white,
    borderColor: Color(0xFFE9E0FF),
    decoration: ModuleDecorationStyle.radialGlow,
    cardRadius: 32,
    filledIcons: true,
    motion: _breathing,
  );

  static const _focusDark = ModuleThemeData(
    module: GoalzyModule.focus,
    primary: Color(0xFFA285FF),
    accent: Color(0xFFC7B6FF),
    surface: Color(0xFF17122A),
    background: Color(0xFF17122A),
    cardColor: Color(0xFF201A38),
    borderColor: Color(0xFF2C2548),
    decoration: ModuleDecorationStyle.radialGlow,
    cardRadius: 32,
    filledIcons: true,
    motion: _breathing,
  );

  // ---------------------------------------------------------------------
  // Profile — premium, personal, the user's journey.
  //
  // The brief specifies Primary #FFFFFF / Accent #D8D8D8 — describing a
  // near-white surface identity, not a usable interactive color. `primary`
  // below is a pragmatic dark-neutral stand-in for buttons/active icons;
  // `surface`/`cardColor` stay true to the near-white spec.
  // ---------------------------------------------------------------------
  static const _profileLight = ModuleThemeData(
    module: GoalzyModule.profile,
    primary: Color(0xFF2C2C2E),
    accent: Color(0xFFD8D8D8),
    surface: Color(0xFFFAFAFA),
    background: Color(0xFFFAFAFA),
    cardColor: Colors.white,
    borderColor: Color(0xFFEAEAEA),
    decoration: ModuleDecorationStyle.texturedWhite,
    cardRadius: 28,
    filledIcons: true,
    motion: _gentle,
  );

  static const _profileDark = ModuleThemeData(
    module: GoalzyModule.profile,
    primary: Color(0xFFE8E8EA),
    accent: Color(0xFF9A9AA0),
    surface: Color(0xFF17171B),
    background: Color(0xFF17171B),
    cardColor: Color(0xFF1F1F24),
    borderColor: Color(0xFF2A2A30),
    decoration: ModuleDecorationStyle.texturedWhite,
    cardRadius: 28,
    filledIcons: true,
    motion: _gentle,
  );

  // ---------------------------------------------------------------------
  // Settings — elegant, simple, Apple-like.
  // ---------------------------------------------------------------------
  static const _settingsLight = ModuleThemeData(
    module: GoalzyModule.settings,
    primary: Color(0xFF7A7A7A),
    accent: Color(0xFFB5B5B5),
    surface: Color(0xFFF8F8F8),
    background: Color(0xFFF8F8F8),
    cardColor: Colors.white,
    borderColor: Color(0xFFE9E9E9),
    decoration: ModuleDecorationStyle.cleanGray,
    cardRadius: 18,
    filledIcons: false,
    motion: _gentle,
  );

  static const _settingsDark = ModuleThemeData(
    module: GoalzyModule.settings,
    primary: Color(0xFFAEAEAE),
    accent: Color(0xFF8A8A8A),
    surface: Color(0xFF1C1C1E),
    background: Color(0xFF1C1C1E),
    cardColor: Color(0xFF242426),
    borderColor: Color(0xFF303032),
    decoration: ModuleDecorationStyle.cleanGray,
    cardRadius: 18,
    filledIcons: false,
    motion: _gentle,
  );
}
