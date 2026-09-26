import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/task_item.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/life_score_card.dart';
import '../../../../shared/widgets/components/progress_card.dart';
import '../../../../shared/widgets/components/section_header.dart';
import '../../../../shared/widgets/components/stat_card.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../../shared/domain/entities/habit.dart';

/// Dashboard — the user's daily story: greeting, today's progress, life
/// score, today's focus, timeline, goals, an AI nudge, quick actions, the
/// week in numbers, habit momentum, a moment of motivation, and recent
/// activity. Cards below pass `useModuleTheme: true` so they pick up the
/// Dashboard module's lavender identity (see core/theme/module_theme.dart)
/// rather than the generic global theme.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? MockData.user;
    final unread = ref.watch(unreadNotificationsCountProvider);
    final lifeScore = MockData.todayLifeScore;
    final responsive = context.responsive;
    final motion = context.moduleTheme.motion;

    final todayAllTasks = MockData.tasks
        .where((t) => t.dueDate != null && goalzy_date.DateUtils.isSameDay(t.dueDate!, DateTime.now()))
        .toList();
    final todayCompletedCount = todayAllTasks.where((t) => t.status == TaskStatus.completed).length;
    final todayOpenTasks = todayAllTasks.where((t) => t.status != TaskStatus.completed).toList();
    final topGoals = MockData.goals.take(3).toList();
    final topHabits = MockData.habits.take(3).toList();
    final weeklyReport = MockData.analytics.weeklyReport;

    Widget staggered(Widget child, int index) {
      return child
          .animate(delay: (index * 70).ms)
          .fadeIn(duration: motion.entranceDuration, curve: motion.entranceCurve)
          .slideY(begin: 0.06, duration: motion.entranceDuration, curve: motion.entranceCurve);
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPadding(
          padding: responsive.pagePadding,
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                staggered(_DashboardHeader(user: user, unread: unread), 0),
                const SizedBox(height: 20),
                staggered(const _SearchBar(), 1),
                const SizedBox(height: 16),
                staggered(
                  _DailyProgressCard(completed: todayCompletedCount, total: todayAllTasks.length),
                  2,
                ),
                const SizedBox(height: 16),
                staggered(LifeScoreCard(lifeScore: lifeScore), 3),
                const SizedBox(height: 24),
                staggered(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: "Today's Focus", icon: Icons.task_alt_rounded, accentColor: context.moduleTheme.primary),
                      if (todayOpenTasks.isEmpty)
                        GlassCard(
                          useModuleTheme: true,
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: AppColors.success, size: 28),
                              const SizedBox(width: 14),
                              Expanded(child: Text('All caught up for today!', style: Theme.of(context).textTheme.bodyLarge)),
                            ],
                          ),
                        )
                      else
                        ...todayOpenTasks.take(3).map((task) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _FocusTaskCard(task: task),
                            )),
                    ],
                  ),
                  4,
                ),
                const SizedBox(height: 8),
                staggered(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Timeline', icon: Icons.schedule_rounded, accentColor: context.moduleTheme.primary),
                      const _TimelineStrip(),
                    ],
                  ),
                  5,
                ),
                const SizedBox(height: 8),
                staggered(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Goal Progress',
                        icon: Icons.flag_rounded,
                        accentColor: context.moduleTheme.primary,
                        actionLabel: 'See all',
                        onAction: () {},
                      ),
                      if (responsive.isPhone)
                        ...topGoals.map((goal) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ProgressCard(
                                title: goal.title,
                                progress: goal.progress,
                                subtitle: '${goal.completedMilestones}/${goal.milestones.length} milestones',
                                color: context.moduleTheme.primary,
                                useModuleTheme: true,
                                onTap: () => context.push('${AppRoutes.home}/goals/${goal.id}'),
                              ),
                            ))
                      else
                        Row(
                          children: topGoals
                              .map((goal) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: ProgressCard(
                                        title: goal.title,
                                        progress: goal.progress,
                                        subtitle: '${(goal.progress * 100).round()}%',
                                        color: context.moduleTheme.primary,
                                        useModuleTheme: true,
                                        onTap: () => context.push('${AppRoutes.home}/goals/${goal.id}'),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                  6,
                ),
                const SizedBox(height: 8),
                staggered(const _AiSuggestionCard(), 7),
                const SizedBox(height: 24),
                staggered(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Quick Actions', icon: Icons.bolt_rounded, accentColor: context.moduleTheme.primary),
                      const _QuickActionsRow(),
                    ],
                  ),
                  8,
                ),
                const SizedBox(height: 8),
                staggered(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Weekly Overview', icon: Icons.bar_chart_rounded, accentColor: context.moduleTheme.primary),
                      _WeeklyOverviewGrid(report: weeklyReport, responsive: responsive),
                    ],
                  ),
                  9,
                ),
                const SizedBox(height: 16),
                staggered(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Habit Progress', icon: Icons.repeat_rounded, accentColor: context.moduleTheme.primary),
                      ...topHabits.map((h) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _HabitProgressTile(habit: h),
                          )),
                    ],
                  ),
                  10,
                ),
                const SizedBox(height: 8),
                staggered(const _MotivationCard(), 11),
                const SizedBox(height: 24),
                staggered(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Recent Activity', icon: Icons.history_rounded, accentColor: context.moduleTheme.primary),
                      ...MockData.recentActivity.map((activity) {
                        final time = activity['time'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            useModuleTheme: true,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: context.moduleTheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(Icons.circle, size: 8, color: context.moduleTheme.primary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${activity['action']}', style: Theme.of(context).textTheme.labelLarge),
                                      Text('${activity['item']}', style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                Text(goalzy_date.DateUtils.formatRelative(time), style: Theme.of(context).textTheme.labelSmall),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  12,
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.user, required this.unread});

  final UserProfile user;
  final int unread;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final accent = context.moduleTheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                user.displayName.split(' ').first,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
              ),
              const SizedBox(height: 4),
              Text(goalzy_date.DateUtils.formatDay(DateTime.now()), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        _HeaderIconButton(
          icon: Icons.notifications_outlined,
          badge: unread > 0 ? '$unread' : null,
          onTap: () => context.push('${AppRoutes.home}/notifications'),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => context.push('${AppRoutes.home}/profile'),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: accent.withValues(alpha: 0.15),
            child: Text(
              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
              style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, this.badge, required this.onTap});

  final IconData icon;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: g.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: g.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: g.textPrimary),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                  child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: g.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: g.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: g.textMuted, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text('Search goals, tasks, habits...', style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// "Daily Progress" — how much of today's task list is done, distinct
/// from the AI-calculated Life Score below it.
class _DailyProgressCard extends StatelessWidget {
  const _DailyProgressCard({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    final g = GoalzyColors.of(context);
    final ratio = total == 0 ? 1.0 : completed / total;

    return GlassCard(
      useModuleTheme: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.today_rounded, color: theme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total == 0 ? 'Nothing scheduled today' : '$completed of $total tasks done today',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: g.chipFill,
                      color: theme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusTaskCard extends StatelessWidget {
  const _FocusTaskCard({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final priorityColor = switch (task.priority) {
      TaskPriority.urgent => AppColors.danger,
      TaskPriority.high => AppColors.warning,
      TaskPriority.medium => context.moduleTheme.primary,
      TaskPriority.low => g.textMuted,
    };

    return GlassCard(
      useModuleTheme: true,
      onTap: () => context.push('${AppRoutes.home}/tasks/${task.id}'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.task_alt_rounded, color: priorityColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: Theme.of(context).textTheme.titleSmall),
                if (task.dueDate != null)
                  Text(goalzy_date.DateUtils.formatTime(task.dueDate!), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: g.textMuted),
        ],
      ),
    );
  }
}

class _TimelineStrip extends StatelessWidget {
  const _TimelineStrip();

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    final events = MockData.calendarEvents.take(4).toList();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final e = events[i];
          return GlassCard(
            useModuleTheme: true,
            padding: const EdgeInsets.all(16),
            margin: EdgeInsets.zero,
            child: SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(goalzy_date.DateUtils.formatTime(e.startTime), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: theme.primary)),
                  const SizedBox(height: 6),
                  Text(e.title, style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AiSuggestionCard extends StatelessWidget {
  const _AiSuggestionCard();

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    return GlassCard(
      useModuleTheme: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: theme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Suggestion', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                Text(
                  'Schedule "Review sprint backlog" before 10 AM for peak focus.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    final actions = [
      (Icons.add_task_rounded, 'Task', () {}),
      (Icons.flag_outlined, 'Goal', () { context.push('${AppRoutes.home}/goals/create'); }),
      (Icons.repeat_rounded, 'Habit', () {}),
      (Icons.self_improvement_rounded, 'Focus', () { context.push('${AppRoutes.home}/focus'); }),
      (Icons.auto_awesome_rounded, 'AI', () {}),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GlassCard(
              useModuleTheme: true,
              onTap: a.$3,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(a.$1, color: theme.primary, size: 24),
                  const SizedBox(height: 8),
                  Text(a.$2, style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Week-in-numbers as individual animated [StatCard]s rather than one flat
/// row of bare numbers — 2x2 on phone, a single row on tablet/desktop.
class _WeeklyOverviewGrid extends StatelessWidget {
  const _WeeklyOverviewGrid({required this.report, required this.responsive});

  final Map<String, dynamic> report;
  final ResponsiveUtils responsive;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (label: 'Tasks', value: report['tasksCompleted'] as int, icon: Icons.task_alt_rounded),
      (label: 'Habits', value: report['habitsLogged'] as int, icon: Icons.repeat_rounded),
      (label: 'Goals', value: report['goalsAdvanced'] as int, icon: Icons.flag_rounded),
      (label: 'XP', value: report['xpEarned'] as int, icon: Icons.bolt_rounded),
    ];

    final cards = stats
        .map((s) => StatCard(label: s.label, value: s.value, icon: s.icon, useModuleTheme: true))
        .toList();

    if (responsive.isPhone) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: cards,
      );
    }

    return Row(
      children: cards
          .map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: c)))
          .toList(),
    );
  }
}

class _HabitProgressTile extends StatelessWidget {
  const _HabitProgressTile({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final color = Color(int.parse('FF${habit.colorHex}', radix: 16));

    return GlassCard(
      useModuleTheme: true,
      child: Row(
        children: [
          Text(habit.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: habit.consistencyRate,
                    minHeight: 8,
                    backgroundColor: g.chipFill,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${habit.streak}d', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Short, rotating encouragement line — the "Motivation" element called
/// for in the design brief. Picked deterministically from the day of the
/// month (same approach as the header's time-of-day greeting) so it's
/// stable across rebuilds rather than re-randomizing on every frame.
const _motivationLines = [
  "Small steps today build the momentum for tomorrow.",
  "Progress, not perfection — you're doing better than you think.",
  "Every habit you keep is a vote for who you're becoming.",
  "Rest is part of the plan too. Pace yourself.",
  "One focused hour beats a scattered day.",
  "You don't need a perfect day, just a consistent one.",
  "Momentum loves company — start with the smallest task.",
];

class _MotivationCard extends StatelessWidget {
  const _MotivationCard();

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    final line = _motivationLines[DateTime.now().day % _motivationLines.length];

    return GlassCard(
      useModuleTheme: true,
      gradient: LinearGradient(
        colors: [theme.primary.withValues(alpha: 0.10), theme.accent.withValues(alpha: 0.06)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.wb_sunny_rounded, color: theme.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              line,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
