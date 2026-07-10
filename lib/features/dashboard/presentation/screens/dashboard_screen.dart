import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/task_item.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/life_score_card.dart';
import '../../../../shared/widgets/components/progress_card.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../../shared/domain/entities/habit.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? MockData.user;
    final unread = ref.watch(unreadNotificationsCountProvider);
    final lifeScore = MockData.todayLifeScore;
    final responsive = context.responsive;
    final g = GoalzyColors.of(context);
    final todayTasks = MockData.tasks
        .where((t) =>
            t.dueDate != null &&
            goalzy_date.DateUtils.isSameDay(t.dueDate!, DateTime.now()) &&
            t.status != TaskStatus.completed)
        .toList();
    final topGoals = MockData.goals.take(3).toList();
    final topHabits = MockData.habits.take(3).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPadding(
          padding: responsive.pagePadding,
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardHeader(user: user, unread: unread).animate().fadeIn().slideY(begin: 0.08, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _SearchBar().animate().fadeIn(delay: 80.ms).slideY(begin: 0.06),
                const SizedBox(height: 24),
                LifeScoreCard(lifeScore: lifeScore).animate().fadeIn(delay: 120.ms).slideY(begin: 0.05),
                const SizedBox(height: 24),
                _SectionTitle(title: "Today's Focus"),
                const SizedBox(height: 12),
                if (todayTasks.isEmpty)
                  GlassCard(
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: AppColors.success, size: 28),
                        const SizedBox(width: 14),
                        Expanded(child: Text('All caught up for today!', style: Theme.of(context).textTheme.bodyLarge)),
                      ],
                    ),
                  )
                else
                  ...todayTasks.take(3).map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _FocusTaskCard(task: task),
                      )),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Timeline'),
                const SizedBox(height: 12),
                _TimelineStrip(),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Goal Progress', action: 'See all', onAction: () {}),
                const SizedBox(height: 12),
                if (responsive.isPhone)
                  ...topGoals.map((goal) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ProgressCard(
                          title: goal.title,
                          progress: goal.progress,
                          subtitle: '${goal.completedMilestones}/${goal.milestones.length} milestones',
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
                                  onTap: () => context.push('${AppRoutes.home}/goals/${goal.id}'),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 24),
                _AiSuggestionCard().animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Quick Actions'),
                const SizedBox(height: 12),
                _QuickActionsRow(),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Weekly Overview'),
                const SizedBox(height: 12),
                _WeeklyOverviewCard(),
                const SizedBox(height: 16),
                _SectionTitle(title: 'Habit Progress'),
                const SizedBox(height: 12),
                ...topHabits.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HabitProgressTile(habit: h),
                    )),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Recent Activity'),
                const SizedBox(height: 12),
                ...MockData.recentActivity.map((activity) {
                  final time = activity['time'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: g.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.circle, size: 8, color: g.primary),
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
            backgroundColor: GoalzyColors.of(context).primary.withValues(alpha: 0.15),
            child: Text(
              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
              style: TextStyle(color: GoalzyColors.of(context).primary, fontWeight: FontWeight.w700, fontSize: 18),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
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
      TaskPriority.medium => g.primary,
      TaskPriority.low => g.textMuted,
    };

    return GlassCard(
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
  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
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
            padding: const EdgeInsets.all(16),
            margin: EdgeInsets.zero,
            child: SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(goalzy_date.DateUtils.formatTime(e.startTime), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: g.primary)),
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
  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: g.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: g.primary, size: 22),
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
  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final actions = [
      (Icons.add_task_rounded, 'Task', () {}),
      (Icons.flag_outlined, 'Goal', () => context.push('${AppRoutes.home}/goals/create')),
      (Icons.repeat_rounded, 'Habit', () {}),
      (Icons.auto_awesome_rounded, 'AI', () {}),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GlassCard(
              onTap: a.$3,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(a.$1, color: g.primary, size: 24),
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

class _WeeklyOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final report = MockData.analytics.weeklyReport;
    final g = GoalzyColors.of(context);

    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatBubble(label: 'Tasks', value: '${report['tasksCompleted']}', color: g.primary),
          _StatBubble(label: 'Habits', value: '${report['habitsLogged']}', color: AppColors.success),
          _StatBubble(label: 'Goals', value: '${report['goalsAdvanced']}', color: AppColors.secondary),
          _StatBubble(label: 'XP', value: '${report['xpEarned']}', color: AppColors.warning),
        ],
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w800)),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
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
