import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/domain/entities/habit.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/progress_ring.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../providers/habits_provider.dart';

/// Habits — growth, consistency, health (see core/theme/module_theme.dart:
/// mint green, organic-blob backdrop, "ripple completion" motion). Loading
/// logic and provider wiring are unchanged; this pass adds a per-habit
/// consistency ring, a real ripple animation on check-off, a fixed weekday
/// label bug in the week grid, and a data-driven motivation line.
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsStateProvider);
    final theme = context.moduleTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _WeekCalendarGrid(habits: state.habits),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _HabitMotivationCard(state: state),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: state.habits.isEmpty
                      ? const EmptyState(title: 'No habits yet', message: 'Build consistency one day at a time', icon: Icons.eco_rounded)
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: state.habits.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final habit = state.habits[index];
                            return _HabitCard(
                              habit: habit,
                              onTap: () => context.push('${AppRoutes.home}/habits/${habit.id}'),
                              onToggle: () {
                                HapticFeedback.lightImpact();
                                ref.read(habitsStateProvider.notifier).toggleToday(habit.id);
                              },
                            )
                                .animate(delay: (index * 60).ms)
                                .fadeIn(duration: theme.motion.entranceDuration, curve: theme.motion.entranceCurve)
                                .slideX(begin: 0.05, duration: theme.motion.entranceDuration, curve: theme.motion.entranceCurve);
                          },
                        ),
                ),
              ],
            ),
        },
      ),
    );
  }
}

class _StreakSummaryCard extends StatelessWidget {
  const _StreakSummaryCard({required this.state});

  final HabitsState state;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final topStreak = state.habits.isEmpty
        ? null
        : state.habits.reduce((a, b) => a.streak > b.streak ? a : b);

    return GlassCard(
      useModuleTheme: true,
      gradient: LinearGradient(
        colors: [AppColors.warning.withValues(alpha: 0.15), g.chipFill],
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

const _weekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class _WeekCalendarGrid extends StatelessWidget {
  const _WeekCalendarGrid({required this.habits});

  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;
    final today = DateTime.now();
    final weekStart = goalzy_date.DateUtils.startOfWeek(today);
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return GlassCard(
      useModuleTheme: true,
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
                    _weekdayLetters[day.weekday - 1],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isToday ? theme.primary : g.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: g.chipFill,
                      border: Border.all(color: isToday ? theme.primary : g.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 32 * fill,
                          color: isToday ? AppColors.success : theme.primary.withValues(alpha: 0.6),
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

/// Short, data-driven encouragement line — reacts to how many habits are
/// actually checked off today rather than showing a fixed message.
class _HabitMotivationCard extends StatelessWidget {
  const _HabitMotivationCard({required this.state});

  final HabitsState state;

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    final total = state.habits.length;
    final done = state.completedToday;

    final String message;
    final IconData icon;
    if (total == 0) {
      message = 'Add your first habit and start building momentum.';
      icon = Icons.eco_rounded;
    } else if (done == total) {
      message = "Every habit checked off today — that's real consistency.";
      icon = Icons.celebration_rounded;
    } else if (done == 0) {
      message = 'Nothing logged yet today. Pick the easiest one and start there.';
      icon = Icons.wb_sunny_rounded;
    } else {
      message = '$done of $total done — keep the streak alive.';
      icon = Icons.local_fire_department_rounded;
    }

    return GlassCard(
      useModuleTheme: true,
      gradient: LinearGradient(
        colors: [theme.primary.withValues(alpha: 0.10), theme.accent.withValues(alpha: 0.06)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
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
      useModuleTheme: true,
      onTap: onTap,
      child: Row(
        children: [
          _HabitCheckRing(completed: habit.completedToday, color: _color, icon: habit.icon, onTap: onToggle),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text('${habit.streak} day streak', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ProgressRing(
            progress: habit.consistencyRate,
            size: 44,
            strokeWidth: 4,
            color: _color,
            child: Text(
              '${(habit.consistencyRate * 100).round()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// The habit's icon chip doubles as its completion toggle. On check-off a
/// ring expands outward from the chip and fades — the "ripple completion"
/// motion called for by the Habits module's design language — rather than
/// an instant icon swap.
class _HabitCheckRing extends StatefulWidget {
  const _HabitCheckRing({required this.completed, required this.color, required this.icon, required this.onTap});

  final bool completed;
  final Color color;
  final String icon;
  final VoidCallback onTap;

  @override
  State<_HabitCheckRing> createState() => _HabitCheckRingState();
}

class _HabitCheckRingState extends State<_HabitCheckRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    if (widget.completed) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant _HabitCheckRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completed != oldWidget.completed) {
      if (widget.completed) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 56,
        height: 56,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                if (t > 0)
                  Container(
                    width: 44 + (t * 20),
                    height: 44 + (t * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.color.withValues(alpha: (1 - t) * 0.6), width: 2),
                    ),
                  ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: widget.completed ? widget.color.withValues(alpha: 0.2) : g.chipFill,
                    border: Border.all(color: widget.completed ? widget.color : g.border),
                  ),
                  child: Center(child: Text(widget.icon, style: const TextStyle(fontSize: 20))),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
