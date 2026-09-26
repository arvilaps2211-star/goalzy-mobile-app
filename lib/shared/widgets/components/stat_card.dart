import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/module_theme_scope.dart';
import 'glass_card.dart';

/// Direction indicator for [StatCard.trendLabel].
enum StatTrend { up, down, flat }

/// Compact statistic tile — animated count-up value, label, optional
/// trend indicator and icon chip.
///
/// Generic building block for Analytics insight grids, Dashboard weekly
/// summaries, Habit streak counts, Profile achievement totals, and any
/// other "number + label" card — built on [GlassCard] so it automatically
/// picks up press-depth feedback and (optionally) module theming.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueSuffix,
    this.trendLabel,
    this.trend,
    this.icon,
    this.color,
    this.onTap,
    this.useModuleTheme = false,
  });

  final String label;

  /// Displayed value. Animates from 0 → [value] on build. Rendered as a
  /// whole number when it has no fractional part, one decimal otherwise.
  final num value;

  /// Optional suffix rendered after the value, e.g. "%", "pts", "days".
  final String? valueSuffix;

  /// e.g. "+12%" or "-3 today" — shown next to the [trend] arrow.
  final String? trendLabel;
  final StatTrend? trend;

  final IconData? icon;

  /// Accent color for the icon chip. Defaults to the theme's primary
  /// color, or `context.moduleTheme.primary` when [useModuleTheme] is
  /// true and no explicit [color] is given.
  final Color? color;

  final VoidCallback? onTap;

  /// When true, sources both the card chrome (via [GlassCard]) and the
  /// default accent color from the nearest module scope.
  final bool useModuleTheme;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final accent = color ?? (useModuleTheme ? context.moduleTheme.primary : g.primary);
    final textTheme = Theme.of(context).textTheme;
    final isWhole = value % 1 == 0;

    final (trendColor, trendIcon) = switch (trend) {
      StatTrend.up => (AppColors.success, Icons.arrow_upward_rounded),
      StatTrend.down => (AppColors.danger, Icons.arrow_downward_rounded),
      StatTrend.flat => (g.textMuted, Icons.remove_rounded),
      null => (g.textMuted, null),
    };

    return GlassCard(
      onTap: onTap,
      useModuleTheme: useModuleTheme,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 15, color: accent),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(label, style: textTheme.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value.toDouble()),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Text(
                  isWhole ? v.round().toString() : v.toStringAsFixed(1),
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (valueSuffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(valueSuffix!, style: textTheme.titleSmall),
                ),
            ],
          ),
          if (trendLabel != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trendIcon != null) ...[
                  Icon(trendIcon, size: 13, color: trendColor),
                  const SizedBox(width: 2),
                ],
                Text(
                  trendLabel!,
                  style: textTheme.labelSmall?.copyWith(color: trendColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
