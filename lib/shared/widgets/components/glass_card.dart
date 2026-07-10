import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Premium floating card — clean iOS-inspired surface with soft shadow.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.gradient,
    this.elevated = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final radius = borderRadius ?? AppConstants.cardRadius;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: gradient == null ? g.surface : null,
        gradient: gradient,
        border: Border.all(color: g.border, width: 1),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: g.shadow,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: g.primary.withValues(alpha: 0.08),
          highlightColor: g.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppConstants.cardPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}
