import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Consistent section title used above card groups and lists.
///
/// Replaces one-off `Text(title, style: textTheme.titleLarge)` rows plus
/// hand-rolled "See all" action rows scattered across screens with a
/// single reusable widget — title, optional subtitle, optional leading
/// icon chip, optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.accentColor,
    this.padding = const EdgeInsets.fromLTRB(4, 0, 4, 12),
  });

  final String title;
  final String? subtitle;

  /// Trailing action text, e.g. "See all". Only shown when [onAction] is
  /// also provided.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Optional small leading icon chip, tinted with [accentColor].
  final IconData? icon;

  /// Tint for [icon] and the action label. Defaults to the global
  /// [GoalzyColors.primary]; pass `context.moduleTheme.primary` at the
  /// call site for a module-tinted header.
  final Color? accentColor;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final accent = accentColor ?? g.primary;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 16, color: accent),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitle != null)
                  Text(subtitle!, style: textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(actionLabel!, style: textTheme.labelLarge?.copyWith(color: accent)),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 18, color: accent),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
