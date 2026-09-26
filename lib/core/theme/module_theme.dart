import 'package:flutter/material.dart';

/// Identifies which "space" of the GOALZY life-OS the user is currently in.
///
/// Each module carries its own color, background, radius, shadow, and
/// motion identity (see [ModuleThemeData]) so the user feels the context
/// shift when moving between them — Dashboard to Habits should feel like
/// entering a different room, while still reading as unmistakably GOALZY.
///
/// Adding a future module (Finance, Learning, Journal, ...) means adding
/// one value here plus one entry in `GoalzyModuleTheme` — never touching
/// individual screens. See GOALZY_BUILD_SPEC.md / the design-system brief
/// for the full rationale.
enum GoalzyModule {
  dashboard,
  goals,
  tasks,
  habits,
  calendar,
  analytics,
  aiAssistant,
  focus,
  profile,
  settings,
}

/// The subtle decorative background pattern a module paints behind its
/// content. Rendered by `ModuleBackground`
/// (lib/shared/widgets/components/module_background.dart). Every pattern
/// is intentionally low-opacity — decoration, never distraction.
enum ModuleDecorationStyle {
  blurredCircles,
  abstractWaves,
  dottedGrid,
  organicBlobs,
  timelineAccents,
  graphLines,
  neuralParticles,
  radialGlow,
  texturedWhite,
  cleanGray,
}

/// Motion tokens for a module.
///
/// Every module reuses the same easing "grammar" — entrance / micro
/// interaction / emphasis / ambient loop — but tunes durations and curves
/// to match its emotional identity. Tasks is fast and snappy; Focus is
/// slow and breathing; Analytics reveals itself gradually. Screens should
/// pull these from `context.moduleTheme.motion` instead of hardcoding
/// durations, so the pacing stays centrally tunable.
@immutable
class ModuleMotion {
  const ModuleMotion({
    required this.entranceDuration,
    required this.entranceCurve,
    required this.microDuration,
    required this.microCurve,
    required this.emphasisDuration,
    required this.emphasisCurve,
    this.ambientLoopDuration,
    this.ambientLoopCurve,
  });

  /// How content fades/slides in when the module first appears — staggered
  /// card entrance, page transitions.
  final Duration entranceDuration;
  final Curve entranceCurve;

  /// Small interactive feedback — checkbox ticks, chip taps, swipe reveal.
  final Duration microDuration;
  final Curve microCurve;

  /// Larger celebratory / confirming motion — completion bursts, milestone
  /// unlocks, streak animations.
  final Duration emphasisDuration;
  final Curve emphasisCurve;

  /// Continuous idle animation — orb glow, breathing timer, pulsing streak.
  /// Null when the module has no ambient loop.
  final Duration? ambientLoopDuration;
  final Curve? ambientLoopCurve;
}

/// Full visual identity for a single module in one brightness mode.
///
/// Resolved via `GoalzyModuleTheme.resolve` and consumed through
/// `context.moduleTheme` once a `ModuleScope` is in the tree. This sits
/// *alongside* the existing global `GoalzyColors` theme extension, it does
/// not replace it — shared chrome (bottom nav, app-level surfaces) keeps
/// using `GoalzyColors`, while module-specific content opts into these
/// tokens as it's migrated over.
@immutable
class ModuleThemeData {
  const ModuleThemeData({
    required this.module,
    required this.primary,
    required this.accent,
    required this.surface,
    required this.background,
    required this.cardColor,
    required this.borderColor,
    required this.decoration,
    required this.cardRadius,
    required this.filledIcons,
    required this.motion,
  });

  final GoalzyModule module;

  /// Main interactive color — buttons, active icons, progress fills.
  final Color primary;

  /// Secondary tint — gradients, highlights, hover/pressed states.
  final Color accent;

  /// Page-level surface tone (distinct from the global background so each
  /// module reads as its own "space").
  final Color surface;

  /// Base scaffold-level background wash for this module.
  final Color background;

  /// Card/container fill color.
  final Color cardColor;

  /// Hairline border tint for cards and dividers within this module.
  final Color borderColor;

  /// Which subtle decorative background pattern this module paints.
  final ModuleDecorationStyle decoration;

  /// Default corner radius for this module's cards/sheets/buttons.
  final double cardRadius;

  /// Whether icons in this module default to filled/rounded (vs outlined).
  final bool filledIcons;

  final ModuleMotion motion;

  /// A soft, module-tinted shadow — replaces flat black card shadows with
  /// a color that matches the module's identity, for a "floating" feel.
  List<BoxShadow> get shadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.14),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -6,
        ),
      ];

  /// Primary → accent gradient, ready for hero surfaces (rings, headers,
  /// FABs) that want the module's full color range.
  LinearGradient get gradient => LinearGradient(
        colors: [primary, accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
