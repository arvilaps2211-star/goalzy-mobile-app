import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/module_theme_scope.dart';

/// Premium floating card — clean iOS-inspired surface with soft shadow and
/// a real tap-depth press response (subtle scale-down while held).
///
/// By default this sources its colors from the global [GoalzyColors]
/// theme, so every existing call site keeps rendering exactly as before.
/// Pass [useModuleTheme]: true to instead source card color / border /
/// shadow / radius from the nearest `ModuleScope` — for screens that have
/// opted into the per-module design language (see core/theme/module_theme.dart).
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.gradient,
    this.elevated = true,
    this.useModuleTheme = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final bool elevated;

  /// When true, sources color/radius/shadow from `context.moduleTheme`
  /// instead of the global [GoalzyColors] theme extension.
  final bool useModuleTheme;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final moduleTheme = widget.useModuleTheme ? context.moduleTheme : null;

    final radius = widget.borderRadius ?? moduleTheme?.cardRadius ?? AppConstants.cardRadius;
    final cardColor = moduleTheme?.cardColor ?? g.surface;
    final borderColor = moduleTheme?.borderColor ?? g.border;
    final shadow = moduleTheme?.shadow ??
        [
          BoxShadow(
            color: g.shadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ];
    final rippleColor = moduleTheme?.primary ?? g.primary;

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: widget.gradient == null ? cardColor : null,
          gradient: widget.gradient,
          border: Border.all(color: borderColor, width: 1),
          boxShadow: widget.elevated ? shadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            borderRadius: BorderRadius.circular(radius),
            splashColor: rippleColor.withValues(alpha: 0.08),
            highlightColor: rippleColor.withValues(alpha: 0.04),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(AppConstants.cardPadding),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
