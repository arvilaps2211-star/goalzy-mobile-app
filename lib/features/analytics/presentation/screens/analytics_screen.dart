import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../core/utils/date_utils.dart' as gd;
import '../../../../shared/domain/entities/analytics.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/life_score_card.dart';
import '../../../../shared/widgets/components/progress_ring.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../providers/analytics_provider.dart';

/// Analytics — insight, intelligence, reflection (see
/// core/theme/module_theme.dart: pink, graph-line backdrop, charts that
/// "reveal" gradually). Provider wiring is unchanged; this pass fixes the
/// same class of hardcoded-light-palette bugs as the other screens, gives
/// the completion-rate bars circular gauges with animated counters (the
/// brief's Analytics section explicitly asks for "circular progress" and
/// "animated counters", not more linear bars), adds a small data-driven
/// Insights section, and wraps both fl_chart charts so they animate in
/// rather than snapping into view. Note: fl_chart's own per-chart
/// swap-animation parameters aren't something I could verify against the
/// vendored package source in this environment, so the "animate while
/// appearing" effect here is done with a plain fade+scale entrance
/// (flutter_animate, already used everywhere else in this app) around the
/// whole chart card instead of relying on an fl_chart API I couldn't check.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsStateProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: state.isLoading
            ? const LoadingState(message: 'Loading analytics...')
            : state.error != null
                ? ErrorState(
                    message: state.error!,
                    onRetry: () => ref.read(analyticsStateProvider.notifier).load(),
                  )
                : state.snapshot == null
                    ? const EmptyState(title: 'No analytics yet', icon: Icons.insights_outlined)
                    : _AnalyticsContent(snapshot: state.snapshot!, reportPeriod: state.reportPeriod),
      ),
    );
  }
}

class _AnalyticsContent extends ConsumerWidget {
  const _AnalyticsContent({required this.snapshot, required this.reportPeriod});

  final AnalyticsSnapshot snapshot;
  final ReportPeriod reportPeriod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;
    final todayScore = snapshot.lifeScoreHistory.isNotEmpty
        ? snapshot.lifeScoreHistory.last
        : LifeScore(
            overall: 0,
            energy: 0,
            focus: 0,
            motivation: 0,
            productivity: 0,
            date: DateTime.now(),
          );

    return RefreshIndicator(
      onRefresh: () => ref.read(analyticsStateProvider.notifier).load(),
      color: theme.primary,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Analytics', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Insights powered by GOALZY Brain', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: g.textSecondary)),
          const SizedBox(height: 20),
          LifeScoreCard(lifeScore: todayScore),
          const SizedBox(height: 20),
          _LifeScoreChart(history: snapshot.lifeScoreHistory)
              .animate()
              .fadeIn(duration: theme.motion.entranceDuration, curve: theme.motion.entranceCurve)
              .scale(begin: const Offset(0.97, 0.97), duration: theme.motion.entranceDuration, curve: theme.motion.entranceCurve),
          const SizedBox(height: 20),
          _InsightsSection(snapshot: snapshot),
          const SizedBox(height: 20),
          _CompletionRates(snapshot: snapshot),
          const SizedBox(height: 20),
          _ReportSection(
            reportPeriod: reportPeriod,
            weeklyReport: snapshot.weeklyReport,
            monthlyReport: snapshot.monthlyReport,
            onPeriodChanged: (p) => ref.read(analyticsStateProvider.notifier).setReportPeriod(p),
          ).animate().fadeIn(duration: theme.motion.entranceDuration, curve: theme.motion.entranceCurve).scale(begin: const Offset(0.97, 0.97)),
        ],
      ),
    );
  }
}

/// Short, data-driven observations rather than decorative filler — the
/// "Insight cards" the brief calls for. These are derived directly from
/// the real snapshot (trend delta, strongest completion rate), not a
/// simulated AI call.
class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.snapshot});

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    final history = snapshot.lifeScoreHistory;
    final insights = <(IconData, String)>[];

    if (history.length >= 2) {
      final delta = history.last.overall - history.first.overall;
      if (delta.abs() >= 1) {
        insights.add((
          delta > 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          delta > 0
              ? 'Life Score is up ${delta.round()} points over this period.'
              : 'Life Score is down ${delta.abs().round()} points over this period.',
        ));
      }
    }

    final rates = {
      'Goals': snapshot.goalCompletionRate,
      'Tasks': snapshot.taskCompletionRate,
      'Habits': snapshot.habitConsistencyRate,
    };
    final strongest = rates.entries.reduce((a, b) => a.value >= b.value ? a : b);
    insights.add((Icons.emoji_events_rounded, '${strongest.key} is your strongest area at ${(strongest.value * 100).round()}% completion.'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Insights', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                useModuleTheme: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(insight.$1, color: theme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(insight.$2, style: Theme.of(context).textTheme.bodyMedium)),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _LifeScoreChart extends StatelessWidget {
  const _LifeScoreChart({required this.history});

  final List<LifeScore> history;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;
    // fl_chart's title/grid-line builder callbacks don't receive a
    // BuildContext, so the dynamic colors are captured here and closed
    // over below rather than looked up inside those callbacks.
    final borderColor = g.border;
    final mutedColor = g.textMuted;

    return GlassCard(
      useModuleTheme: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Life Score Trend', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('7-day overview', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (_) => FlLine(color: borderColor, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(fontSize: 10, color: mutedColor)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= history.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            gd.DateUtils.formatShort(history[i].date),
                            style: TextStyle(fontSize: 10, color: mutedColor),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 50,
                maxY: 100,
                lineBarsData: [
                  _line(history.map((s) => s.overall).toList(), theme.primary),
                  _line(history.map((s) => s.energy).toList(), AppColors.warning),
                  _line(history.map((s) => s.focus).toList(), AppColors.secondary),
                  _line(history.map((s) => s.productivity).toList(), AppColors.success),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _ChartLegend(color: theme.primary, label: 'Overall'),
              const _ChartLegend(color: AppColors.warning, label: 'Energy'),
              const _ChartLegend(color: AppColors.secondary, label: 'Focus'),
              const _ChartLegend(color: AppColors.success, label: 'Productivity'),
            ],
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(List<double> values, Color color) {
    return LineChartBarData(
      spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i])),
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

/// Performance metrics as circular gauges with animated count-up
/// percentages, rather than the flat linear bars used before — the
/// brief's Analytics section explicitly calls for "circular progress" and
/// "animated counters".
class _CompletionRates extends StatelessWidget {
  const _CompletionRates({required this.snapshot});

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    final metrics = [
      ('Goals', snapshot.goalCompletionRate, theme.primary, Icons.flag_outlined),
      ('Tasks', snapshot.taskCompletionRate, AppColors.secondary, Icons.task_alt_outlined),
      ('Habits', snapshot.habitConsistencyRate, AppColors.success, Icons.repeat),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Performance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: metrics
              .map((m) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: GlassCard(
                        useModuleTheme: true,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                        child: Column(
                          children: [
                            ProgressRing(
                              progress: m.$2,
                              size: 64,
                              strokeWidth: 6,
                              color: m.$3,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: m.$2 * 100),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, __) => Text(
                                  '${v.round()}%',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Icon(m.$4, color: m.$3, size: 16),
                            const SizedBox(height: 4),
                            Text(m.$1, style: Theme.of(context).textTheme.labelMedium),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.reportPeriod,
    required this.weeklyReport,
    required this.monthlyReport,
    required this.onPeriodChanged,
  });

  final ReportPeriod reportPeriod;
  final Map<String, dynamic> weeklyReport;
  final Map<String, dynamic> monthlyReport;
  final ValueChanged<ReportPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;
    final borderColor = g.border;
    final mutedColor = g.textMuted;
    final report = reportPeriod == ReportPeriod.weekly ? weeklyReport : monthlyReport;
    final entries = report.entries.toList();

    return GlassCard(
      useModuleTheme: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Reports', style: Theme.of(context).textTheme.titleMedium)),
              _PeriodToggle(selected: reportPeriod, onChanged: onPeriodChanged),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: entries.map((e) => (e.value as num).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: borderColor, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(fontSize: 10, color: mutedColor)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (i, _) {
                        if (i.toInt() >= entries.length) return const SizedBox.shrink();
                        final label = _formatKey(entries[i.toInt()].key);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(label, style: TextStyle(fontSize: 9, color: mutedColor)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  entries.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: (entries[i].value as num).toDouble(),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        gradient: theme.gradient,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatKey(e.key), style: Theme.of(context).textTheme.bodyMedium),
                    Text('${e.value}', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: theme.primary)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}').trim().split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.selected, required this.onChanged});

  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: g.chipFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: g.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'Weekly',
            selected: selected == ReportPeriod.weekly,
            onTap: () => onChanged(ReportPeriod.weekly),
          ),
          _ToggleChip(
            label: 'Monthly',
            selected: selected == ReportPeriod.monthly,
            onTap: () => onChanged(ReportPeriod.monthly),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: selected ? theme.gradient : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : g.textSecondary,
          ),
        ),
      ),
    );
  }
}
