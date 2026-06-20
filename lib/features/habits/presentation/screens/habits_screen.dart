import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/domain/entities/habit.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/progress_ring.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../providers/habits_provider.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsStateProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          child: switch (true) {
            _ when state.isLoading => const LoadingState(message: 'Loading habits...'),
            _ when state.error != null => ErrorState(message: state.error!, onRetry: () => ref.read(habitsStateProvider.notifier).loadHabits()),
            _ => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Habits', style: Theme.of(context).textTheme.headlineMedium),
                        Text(
                          '${state.completedToday}/${state.habits.length} done today · ${(state.avgConsistency * 100).round()}% consistency',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _StreakSummaryCard(state: state),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _WeekCalendarGrid(habits: state.habits),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: state.habits.isEmpty
                        ? const EmptyState(title: 'No habits yet', message: 'Build consistency one day at a time', icon: Icons.loop)
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: state.habits.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final habit = state.habits[index];
                              return _HabitCard(
                                habit: habit,
                                onTap: () => context.push('${AppRoutes.home}/habits/${habit.id}'),
                                onToggle: () => ref.read(habitsStateProvider.notifier).toggleToday(habit.id),
                              ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.05);
                            },
                          ),
                  ),
                ],
              ),
          },
        ),
      ),
    );
  }
}

class _StreakSummaryCard extends StatelessWidget {
  const _StreakSummaryCard({required this.state});

  final HabitsState state;

  @override
  Widget build(BuildContext context) {
    final topStreak = state.habits.isEmpty
        ? null
        : state.habits.reduce((a, b) => a.streak > b.streak ? a : b);

    return GlassCard(
      gradient: LinearGradient(
        colors: [AppColors.warning.withValues(alpha: 0.15), AppColors.glassFill],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${state.totalStreak} total streak days', style: Theme.of(context).textTheme.titleMedium),
                if (topStreak != null)
                  Text('Leader: ${topStreak.title} (${topStreak.streak} days)', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          ProgressRing(
            progress: state.avgConsistency,
            size: 52,
            strokeWidth: 5,
            color: AppColors.warning,
            child: Text('${(state.avgConsistency * 100).round()}%', style: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      ),
    );
  }
}

class _WeekCalendarGrid extends StatelessWidget {
  const _WeekCalendarGrid({required this.habits});

  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekStart = goalzy_date.DateUtils.startOfWeek(today);
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Week', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isToday = goalzy_date.DateUtils.isSameDay(day, today);
              final completedCount = habits.where((h) => h.completedToday && isToday).length;
              final fill = isToday ? (habits.isEmpty ? 0.0 : completedCount / habits.length) : _mockDayFill(day);

              return Column(
                children: [
                  Text(
                    goalzy_date.DateUtils.formatShort(day).split(' ').last,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isToday ? AppColors.primary : AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.glassFill,
                      border: Border.all(color: isToday ? AppColors.primary : AppColors.glassBorder),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 32 * fill,
                          color: isToday ? AppColors.success : AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  double _mockDayFill(DateTime day) {
    final hash = day.weekday + day.day;
    return [0.3, 0.5, 0.7, 0.4, 0.8, 0.6, 0.9][hash % 7];
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({required this.habit, required this.onTap, required this.onToggle});

  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  Color get _color => Color(int.parse('FF${habit.colorHex}', radix: 16));

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: habit.completedToday ? _color.withValues(alpha: 0.2) : AppColors.glassFill,
                border: Border.all(color: habit.completedToday ? _color : AppColors.glassBorder),
              ),
              child: Center(child: Text(habit.icon, style: const TextStyle(fontSize: 20))),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text('${habit.streak} day streak', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 12),
                    Text('${(habit.consistencyRate * 100).round()}% consistent', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            habit.completedToday ? Icons.check_circle : Icons.radio_button_unchecked,
            color: habit.completedToday ? AppColors.success : AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
