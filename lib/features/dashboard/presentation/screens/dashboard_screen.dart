import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? MockData.user;
    final lifeScore = MockData.todayLifeScore;
    final responsive = context.responsive;
    final todayTasks = MockData.tasks
        .where((t) =>
            t.dueDate != null &&
            goalzy_date.DateUtils.isSameDay(t.dueDate!, DateTime.now()) &&
            t.status != TaskStatus.completed)
        .toList();
    final topGoals = MockData.goals.take(3).toList();
    final topHabits = MockData.habits.take(3).toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: responsive.pagePadding.copyWith(bottom: 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_greeting()}, ${user.displayName.split(' ').first}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 4),
                Text(
                  goalzy_date.DateUtils.formatDay(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _StatsRow(user: user),
                const SizedBox(height: 16),
                LifeScoreCard(lifeScore: lifeScore),
                const SizedBox(height: 20),
                _SectionHeader(title: "Today's Tasks", action: 'See all', onAction: () {}),
                const SizedBox(height: 12),
                if (todayTasks.isEmpty)
                  GlassCard(
                    child: Text('All caught up!', style: Theme.of(context).textTheme.bodyMedium),
                  )
                else
                  ...todayTasks.map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TaskTile(task: task),
                      )),
                const SizedBox(height: 12),
                _SectionHeader(title: 'Goal Progress', action: 'Goals', onAction: () {}),
                const SizedBox(height: 12),
                if (responsive.isPhone)
                  ...topGoals.map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ProgressCard(
                          title: g.title,
                          progress: g.progress,
                          subtitle: '${g.completedMilestones}/${g.milestones.length} milestones',
                          onTap: () => context.push('${AppRoutes.home}/goals/${g.id}'),
                        ),
                      ))
                else
                  Row(
                    children: topGoals
                        .map((g) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ProgressCard(
                                  title: g.title,
                                  progress: g.progress,
                                  subtitle: '${(g.progress * 100).round()}%',
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 12),
                _SectionHeader(title: 'Habit Progress', action: 'Habits', onAction: () {}),
                const SizedBox(height: 12),
                ...topHabits.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        child: Row(
                          children: [
                            Text(h.icon, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h.title, style: Theme.of(context).textTheme.titleSmall),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: h.consistencyRate,
                                      minHeight: 6,
                                      backgroundColor: AppColors.glassFill,
                                      color: Color(int.parse('FF${h.colorHex}', radix: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('${h.streak}d', style: Theme.of(context).textTheme.labelLarge),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 12),
                _SectionHeader(title: 'AI Suggestions'),
                const SizedBox(height: 12),
                GlassCard(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Schedule "Review sprint backlog" before 10 AM for peak focus.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _QuickActionChip(icon: Icons.add_task, label: 'Add Task', onTap: () {}),
                    _QuickActionChip(icon: Icons.flag_outlined, label: 'New Goal', onTap: () => context.push('${AppRoutes.home}/goals/create')),
                    _QuickActionChip(icon: Icons.repeat, label: 'Log Habit', onTap: () {}),
                    _QuickActionChip(icon: Icons.auto_awesome, label: 'Ask AI', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionHeader(title: 'Recent Activity'),
                const SizedBox(height: 12),
                ...MockData.recentActivity.map((activity) {
                  final time = activity['time'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${activity['action']}', style: Theme.of(context).textTheme.labelMedium),
                                Text('${activity['item']}', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Text(goalzy_date.DateUtils.formatRelative(time),
                              style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MiniStat(icon: Icons.bolt, label: 'XP', value: '${user.xp}')),
        const SizedBox(width: 10),
        Expanded(child: _MiniStat(icon: Icons.monetization_on_outlined, label: 'Credits', value: '${user.credits}')),
        const SizedBox(width: 10),
        Expanded(child: _MiniStat(icon: Icons.local_fire_department, label: 'Streak', value: '${user.streakDays}d')),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});

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

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (task.priority) {
      TaskPriority.urgent => AppColors.danger,
      TaskPriority.high => AppColors.warning,
      TaskPriority.medium => AppColors.secondary,
      TaskPriority.low => AppColors.textMuted,
    };

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () => context.push('${AppRoutes.home}/tasks/${task.id}'),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: Theme.of(context).textTheme.titleSmall),
                if (task.dueDate != null)
                  Text(goalzy_date.DateUtils.formatTime(task.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(_priorityIcon(task.priority), color: priorityColor, size: 18),
        ],
      ),
    );
  }

  IconData _priorityIcon(TaskPriority priority) => switch (priority) {
        TaskPriority.urgent => Icons.priority_high,
        TaskPriority.high => Icons.arrow_upward,
        TaskPriority.medium => Icons.remove,
        TaskPriority.low => Icons.arrow_downward,
      };
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
