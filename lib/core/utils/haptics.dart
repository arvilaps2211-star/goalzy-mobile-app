import 'package:flutter/services.dart';

/// Thin, semantically-named wrapper around Flutter's [HapticFeedback] API.
///
/// Centralizes "which haptic for which interaction" in one place rather
/// than scattering raw `HapticFeedback.xImpact()` calls through the
/// codebase, so the choices are easy to find and adjust later. Wired into
/// the shared component library (GlassButton, GlassCard) rather than
/// individual screens — every button and interactive card in the app
/// picks this up automatically.
///
/// [HapticFeedback] calls are safe no-ops on platforms/devices without
/// haptic hardware (desktop, web, simulators without haptics), so nothing
/// here needs a platform check.
abstract final class Haptics {
  /// Light, quick feedback for buttons and interactive cards — fires on
  /// touch-down, matching how iOS's own controls behave (immediate
  /// feedback on contact, not on release).
  static void tap() => HapticFeedback.lightImpact();

  /// A meaningful state change completing — a task/habit checked off, a
  /// swipe action landing.
  static void confirm() => HapticFeedback.mediumImpact();

  /// Picking between discrete options — segmented controls, filter chips,
  /// radio-style selection.
  static void select() => HapticFeedback.selectionClick();

  /// Reserved for genuinely significant moments — a completed focus
  /// session. Heavier than [confirm].
  static void celebrate() => HapticFeedback.heavyImpact();
}
