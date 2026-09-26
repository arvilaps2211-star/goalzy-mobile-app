import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'glass_card.dart';
import 'progress_ring.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
    this.useModuleTheme = false,
  });

  final String title;
  final double progress;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  /// When true, the underlying [GlassCard] sources its chrome (card color,
  /// border, shadow, radius) from the nearest module scope, matching
  /// [color] if it was also derived from `context.moduleTheme`.
  final bool useModuleTheme;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      useModuleTheme: useModuleTheme,
      child: Row(
        children: [
          ProgressRing(
            progress: progress,
            size: 52,
            strokeWidth: 5,
            color: color ?? AppColors.primary,
            child: Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                if (subtitle != null)
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (icon != null) Icon(icon, color: color ?? AppColors.primary, size: 20),
        ],
      ),
    );
  }
}
