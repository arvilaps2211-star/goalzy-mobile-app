import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../domain/entities/analytics.dart';
import 'glass_card.dart';
import 'progress_ring.dart';

class LifeScoreCard extends StatelessWidget {
  const LifeScoreCard({super.key, required this.lifeScore, this.compact = false});

  final LifeScore lifeScore;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return GlassCard(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        child: Row(
          children: [
            ProgressRing(
              progress: lifeScore.overall / 100,
              size: 64,
              child: Text(
                lifeScore.overall.round().toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Life Score', style: Theme.of(context).textTheme.titleMedium),
                  Text('Your overall life balance', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: 0.25),
          AppColors.surface.withValues(alpha: 0.5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProgressRing(
                progress: lifeScore.overall / 100,
                size: 88,
                strokeWidth: 7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lifeScore.overall.round().toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text('Score', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Life Score', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text('AI-calculated life balance', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MetricBar(label: 'Energy', value: lifeScore.energy, color: AppColors.warning),
          const SizedBox(height: 10),
          _MetricBar(label: 'Focus', value: lifeScore.focus, color: AppColors.secondary),
          const SizedBox(height: 10),
          _MetricBar(label: 'Motivation', value: lifeScore.motivation, color: AppColors.primary),
          const SizedBox(height: 10),
          _MetricBar(label: 'Productivity', value: lifeScore.productivity, color: AppColors.success),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: Theme.of(context).textTheme.labelMedium)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              backgroundColor: AppColors.glassFill,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${value.round()}', style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
