import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/domain/entities/habit.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/progress_ring.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../providers/habits_provider.dart';

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsState = ref.watch(habitsStateProvider);
    final habit = habitsState.habits.where((h) => h.id == habitId).firstOrNull;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          child: switch (true) {
            _ when habitsState.isLoading && habit == null => const LoadingState(message: 'Loading habit...'),
            _ when habitsState.error != null && habit == null => ErrorState(message: habitsState.error!),
            _ when habit == null => const EmptyState(title: 'Habit not found', icon: Icons.loop),
            _ => _HabitDetailBody(habit: habit),
          },
        ),
      ),
    );
  }
}

class _HabitDetailBody extends ConsumerWidget {
  const _HabitDetailBody({required this.habit});

  final Habit habit;

  Color get _color => Color(int.parse('FF${habit.colorHex}', radix: 16));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () async {
                await ref.read(habitsStateProvider.notifier).deleteHabit(habit.id);
                if (context.mounted) context.pop();
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              GlassCard(
                gradient: LinearGradient(
                  colors: [_color.withValues(alpha: 0.15), AppColors.glassFill],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _color.withValues(alpha: 0.2),
                        border: Border.all(color: _color.withValues(alpha: 0.4)),
                      ),
                      child: Center(child: Text(habit.icon, style: const TextStyle(fontSize: 32))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(habit.title, style: Theme.of(context).textTheme.headlineSmall),
                          if (habit.description.isNotEmpty)
                            Text(habit.description, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(_frequencyLabel(habit.frequency), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Current Streak', value: '${habit.streak}', icon: '🔥', color: AppColors.warning)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Best Streak', value: '${habit.bestStreak}', icon: '🏆', color: AppColors.secondary)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Consistency', value: '${(habit.consistencyRate * 100).round()}%', icon: '📈', color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 20),
              Text('Consistency', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              GlassCard(
                child: Row(
                  children: [
                    ProgressRing(
                      progress: habit.consistencyRate,
                      size: 72,
                      color: _color,
                      child: Text('${(habit.consistencyRate * 100).round()}%', style: Theme.of(context).textTheme.labelMedium),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${habit.targetDays} day target cycle', style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: habit.consistencyRate,
                              minHeight: 8,
                              backgroundColor: AppColors.glassFill,
                              color: _color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Calendar', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              GlassCard(
                child: _MonthCalendarGrid(habit: habit),
              ),
              const SizedBox(height: 24),
              GlassButton(
                label: habit.completedToday ? 'Undo Today' : 'Complete Today',
                expanded: true,
                icon: habit.completedToday ? Icons.undo : Icons.check,
                onPressed: () => ref.read(habitsStateProvider.notifier).toggleToday(habit.id),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
          Text(label, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _MonthCalendarGrid extends StatelessWidget {
  const _MonthCalendarGrid({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(goalzy_date.DateUtils.formatMonth(now), style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Text(d, style: Theme.of(context).textTheme.labelSmall))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6),
          itemCount: firstWeekday - 1 + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) return const SizedBox.shrink();

            final day = index - (firstWeekday - 1) + 1;
            final date = DateTime(now.year, now.month, day);
            final isToday = goalzy_date.DateUtils.isSameDay(date, now);
            final isFuture = date.isAfter(now);
            final completed = !isFuture && _isDayCompleted(day, habit);

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: completed
                    ? Color(int.parse('FF${habit.colorHex}', radix: 16)).withValues(alpha: 0.35)
                    : AppColors.glassFill,
                border: Border.all(color: isToday ? AppColors.primary : AppColors.glassBorder),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: completed ? AppColors.textPrimary : AppColors.textMuted,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  bool _isDayCompleted(int day, Habit habit) {
    final hash = (habit.id.hashCode + day) % 10;
    return hash < (habit.consistencyRate * 10).round();
  }
}

String _frequencyLabel(HabitFrequency frequency) => switch (frequency) {
      HabitFrequency.daily => 'Daily',
      HabitFrequency.weekly => 'Weekly',
      HabitFrequency.custom => 'Custom schedule',
    };
