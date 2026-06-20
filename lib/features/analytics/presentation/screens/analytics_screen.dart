import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as gd;
import '../../../../shared/domain/entities/analytics.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/life_score_card.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
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
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Analytics', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Insights powered by GOALZY Brain', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          LifeScoreCard(lifeScore: todayScore),
          const SizedBox(height: 20),
          _LifeScoreChart(history: snapshot.lifeScoreHistory),
          const SizedBox(height: 20),
          _CompletionRates(snapshot: snapshot),
          const SizedBox(height: 20),
          _ReportSection(
            reportPeriod: reportPeriod,
            weeklyReport: snapshot.weeklyReport,
            monthlyReport: snapshot.monthlyReport,
            onPeriodChanged: (p) => ref.read(analyticsStateProvider.notifier).setReportPeriod(p),
          ),
        ],
      ),
    );
  }
}

class _LifeScoreChart extends StatelessWidget {
  const _LifeScoreChart({required this.history});

  final List<LifeScore> history;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.glassBorder, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
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
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
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
                  _line(history.map((s) => s.overall).toList(), AppColors.primary),
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
            children: const [
              _ChartLegend(color: AppColors.primary, label: 'Overall'),
              _ChartLegend(color: AppColors.warning, label: 'Energy'),
              _ChartLegend(color: AppColors.secondary, label: 'Focus'),
              _ChartLegend(color: AppColors.success, label: 'Productivity'),
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

class _CompletionRates extends StatelessWidget {
  const _CompletionRates({required this.snapshot});

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Goals', snapshot.goalCompletionRate, AppColors.primary, Icons.flag_outlined),
      ('Tasks', snapshot.taskCompletionRate, AppColors.secondary, Icons.task_alt_outlined),
      ('Habits', snapshot.habitConsistencyRate, AppColors.success, Icons.repeat),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Performance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...metrics.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Row(
                  children: [
                    Icon(m.$4, color: m.$3, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.$1, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: m.$2,
                              minHeight: 8,
                              backgroundColor: AppColors.glassFill,
                              color: m.$3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${(m.$2 * 100).round()}%', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: m.$3)),
                  ],
                ),
              ),
            )),
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
    final report = reportPeriod == ReportPeriod.weekly ? weeklyReport : monthlyReport;
    final entries = report.entries.toList();

    return GlassCard(
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
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.glassBorder, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
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
                          child: Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
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
                        gradient: AppColors.primaryGradient,
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
                    Text('${e.value}', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondary)),
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: selected ? AppColors.primaryGradient : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
