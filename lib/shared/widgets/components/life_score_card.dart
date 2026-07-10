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
    final g = GoalzyColors.of(context);

    if (compact) {
      return GlassCard(
        child: Row(
          children: [
            ProgressRing(
              progress: lifeScore.overall / 100,
              size: 72,
              strokeWidth: 6,
              child: Text(
                lifeScore.overall.round().toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Life Score', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Your overall balance today', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProgressRing(
                progress: lifeScore.overall / 100,
                size: 96,
                strokeWidth: 7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lifeScore.overall.round().toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text('Score', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Life Score', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text('AI-calculated life balance', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _MetricBar(label: 'Energy', value: lifeScore.energy, color: AppColors.warning),
          const SizedBox(height: 12),
          _MetricBar(label: 'Focus', value: lifeScore.focus, color: g.primary),
          const SizedBox(height: 12),
          _MetricBar(label: 'Motivation', value: lifeScore.motivation, color: AppColors.secondary),
          const SizedBox(height: 12),
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
    final g = GoalzyColors.of(context);
    return Row(
      children: [
        SizedBox(width: 96, child: Text(label, style: Theme.of(context).textTheme.labelMedium)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / 100),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: g.chipFill,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('${value.round()}', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
