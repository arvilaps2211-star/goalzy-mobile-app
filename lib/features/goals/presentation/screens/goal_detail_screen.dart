import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/module_theme.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/domain/entities/goal.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/module_background.dart';
import '../../../../shared/widgets/components/progress_ring.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../providers/goals_provider.dart';

/// Pushed as a standalone page outside the shell (see task_detail_screen
/// .dart's doc comment for why) — explicitly opted into the Goals module.
class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsState = ref.watch(goalsStateProvider);
    final goal = goalsState.goals.where((g) => g.id == goalId).firstOrNull;

    return ModuleScope(
      module: GoalzyModule.goals,
      child: Builder(
        builder: (context) {
          final theme = context.moduleTheme;
          return Scaffold(
            backgroundColor: theme.background,
            body: Stack(
              children: [
                const Positioned.fill(child: ModuleBackground()),
                SafeArea(
                  child: switch (true) {
                    _ when goalsState.isLoading && goal == null => const LoadingState(message: 'Loading goal...'),
                    _ when goalsState.error != null && goal == null => ErrorState(message: goalsState.error!),
                    _ when goal == null => const EmptyState(title: 'Goal not found', icon: Icons.flag_outlined),
                    _ => _GoalDetailBody(goal: goal),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GoalDetailBody extends ConsumerWidget {
  const _GoalDetailBody({required this.goal});

  final Goal goal;

  Color get _color => Color(int.parse('FF${goal.colorHex}', radix: 16));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = GoalzyColors.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          title: Text(goal.title, style: Theme.of(context).textTheme.titleLarge),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () async {
                await ref.read(goalsStateProvider.notifier).deleteGoal(goal.id);
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
                useModuleTheme: true,
                gradient: LinearGradient(
                  colors: [_color.withValues(alpha: 0.15), g.chipFill],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Row(
                  children: [
                    ProgressRing(
                      progress: goal.progress,
                      size: 88,
                      color: _color,
                      child: Text(
                        '${(goal.progress * 100).round()}%',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_categoryLabel(goal.category), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _color)),
                          const SizedBox(height: 4),
                          Text(goal.description, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: g.textMuted),
                              const SizedBox(width: 4),
                              Text('Target ${goalzy_date.DateUtils.formatDate(goal.targetDate)}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 20),
              Text('Milestones', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (goal.milestones.isEmpty)
                GlassCard(
                  useModuleTheme: true,
                  child: Text('No milestones yet. Add checkpoints to track your roadmap.', style: TextStyle(color: g.textMuted)),
                )
              else
                ...goal.milestones.mapIndexed((i, milestone) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      useModuleTheme: true,
                      onTap: () => ref.read(goalsStateProvider.notifier).toggleMilestone(goal.id, milestone.id),
                      child: Row(
                        children: [
                          Icon(
                            milestone.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: milestone.isCompleted ? AppColors.success : g.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  milestone.title,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                                        color: milestone.isCompleted ? g.textMuted : g.textPrimary,
                                      ),
                                ),
                                Text(goalzy_date.DateUtils.formatShort(milestone.targetDate), style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.05);
                }),
              const SizedBox(height: 20),
              Text('Roadmap', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              GlassCard(
                useModuleTheme: true,
                child: Column(
                  children: goal.milestones.isEmpty
                      ? [Text('Your roadmap will appear here', style: Theme.of(context).textTheme.bodyMedium)]
                      : goal.milestones.asMap().entries.map((entry) {
                          final i = entry.key;
                          final m = entry.value;
                          final isLast = i == goal.milestones.length - 1;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: m.isCompleted ? AppColors.success.withValues(alpha: 0.2) : g.chipFill,
                                      border: Border.all(color: m.isCompleted ? AppColors.success : g.border),
                                    ),
                                    child: Icon(
                                      m.isCompleted ? Icons.check : Icons.circle,
                                      size: 14,
                                      color: m.isCompleted ? AppColors.success : g.textMuted,
                                    ),
                                  ),
                                  if (!isLast) Container(width: 2, height: 32, color: g.border),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m.title, style: Theme.of(context).textTheme.titleSmall),
                                      Text(goalzy_date.DateUtils.formatDate(m.targetDate), style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Text('Progress', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              GlassCard(
                useModuleTheme: true,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatChip(label: 'Overall', value: '${(goal.progress * 100).round()}%', color: _color),
                        _StatChip(label: 'Milestones', value: '${goal.completedMilestones}/${goal.milestones.length}', color: AppColors.secondary),
                        _StatChip(label: 'Status', value: _statusLabel(goal.status), color: AppColors.success),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: goal.progress),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, value, __) => LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor: g.chipFill,
                          color: _color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GlassButton(
                label: goal.status == GoalStatus.completed ? 'Mark Active' : 'Mark Complete',
                expanded: true,
                variant: goal.status == GoalStatus.completed ? GlassButtonVariant.secondary : GlassButtonVariant.primary,
                onPressed: () {
                  final newStatus = goal.status == GoalStatus.completed ? GoalStatus.active : GoalStatus.completed;
                  ref.read(goalsStateProvider.notifier).updateGoal(
                        goal.copyWith(
                          status: newStatus,
                          progress: newStatus == GoalStatus.completed ? 1.0 : goal.progress,
                        ),
                      );
                },
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

String _categoryLabel(GoalCategory category) => switch (category) {
      GoalCategory.career => 'Career',
      GoalCategory.health => 'Health',
      GoalCategory.finance => 'Finance',
      GoalCategory.learning => 'Learning',
      GoalCategory.personal => 'Personal',
      GoalCategory.fitness => 'Fitness',
      GoalCategory.other => 'Other',
    };

String _statusLabel(GoalStatus status) => switch (status) {
      GoalStatus.active => 'Active',
      GoalStatus.completed => 'Done',
      GoalStatus.paused => 'Paused',
      GoalStatus.archived => 'Archived',
    };
