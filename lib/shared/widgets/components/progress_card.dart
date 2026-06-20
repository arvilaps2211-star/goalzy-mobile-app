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
  });

  final String title;
  final double progress;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
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
