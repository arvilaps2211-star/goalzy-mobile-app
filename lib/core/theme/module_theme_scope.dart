import 'package:flutter/material.dart';
import 'module_theme.dart';
import 'module_theme_registry.dart';

/// Establishes which [GoalzyModule] the current subtree belongs to and
/// resolves its [ModuleThemeData] for the ambient brightness.
///
/// Wrap a tab's screen (or any module-specific subtree) in [ModuleScope] to
/// make `context.moduleTheme` / `context.goalzyModule` available to
/// everything below it. Today this is consumed by `ModuleBackground`;
/// later milestones will have screen components (cards, headers, charts)
/// read from it too.
///
/// This is purely additive — nothing outside the background layer reads
/// from it yet, so wrapping a screen in [ModuleScope] cannot change its
/// existing visual behavior.
class ModuleScope extends StatelessWidget {
  const ModuleScope({super.key, required this.module, required this.child});

  final GoalzyModule module;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final data = GoalzyModuleTheme.resolve(module, brightness);
    return ModuleThemeScope._(module: module, data: data, child: child);
  }
}

class ModuleThemeScope extends InheritedWidget {
  const ModuleThemeScope._({
    required this.module,
    required this.data,
    required super.child,
  });

  final GoalzyModule module;
  final ModuleThemeData data;

  /// Falls back to Dashboard's light theme when no [ModuleScope] is
  /// present, so callers never need a null check.
  static ModuleThemeData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ModuleThemeScope>();
    return scope?.data ?? GoalzyModuleTheme.resolve(GoalzyModule.dashboard, Brightness.light);
  }

  static GoalzyModule moduleOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ModuleThemeScope>();
    return scope?.module ?? GoalzyModule.dashboard;
  }

  @override
  bool updateShouldNotify(ModuleThemeScope oldWidget) =>
      module != oldWidget.module || data != oldWidget.data;
}

extension ModuleThemeContextX on BuildContext {
  /// The resolved color/motion/decoration tokens for the nearest
  /// [ModuleScope] ancestor (or Dashboard's light theme as a safe default).
  ModuleThemeData get moduleTheme => ModuleThemeScope.of(this);

  /// The nearest [ModuleScope]'s module identity.
  GoalzyModule get goalzyModule => ModuleThemeScope.moduleOf(this);
}
