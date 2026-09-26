import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/domain/entities/goal.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/progress_ring.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../providers/goals_provider.dart';

/// Goals — purpose, direction, achievement (see
/// core/theme/module_theme.dart: violet, abstract-wave backdrop, "progress
/// grows smoothly" motion). Provider wiring is unchanged; this pass gives
/// the List tab its own bespoke "premium goal card" (the brief's Goals
/// section explicitly calls for this, distinct from the generic
/// ProgressCard used elsewhere) with a real milestone visualization, fixes
/// the same class of hardcoded-light-palette bugs as the other screens,
/// and animates the Timeline tab's progress bar, which previously snapped
/// instantly while the ring-based tabs already animated smoothly.
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalsStateProvider);
    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Goals', style: Theme.of(context).textTheme.headlineMedium),
                        Text(
                          '${state.activeGoals.length} active · ${(state.goals.fold<double>(0, (s, g) => s + g.progress) / (state.goals.isEmpty ? 1 : state.goals.length) * 100).round()}% avg progress',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  GlassButton(
                    label: 'New',
                    icon: Icons.add,
                    onPressed: () => context.push('${AppRoutes.home}/goals/create'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: _tabController,
                indicatorColor: theme.primary,
                labelColor: g.textPrimary,
                unselectedLabelColor: g.textMuted,
                dividerColor: g.border,
                tabs: const [
                  Tab(text: 'List'),
                  Tab(text: 'Categories'),
                  Tab(text: 'Timeline'),
                ],
              ),
            ),
            Expanded(
              child: switch (true) {
                _ when state.isLoading => const LoadingState(message: 'Loading goals...'),
                _ when state.error != null => ErrorState(message: state.error!, onRetry: () => ref.read(goalsStateProvider.notifier).loadGoals()),
                _ when state.goals.isEmpty => EmptyState(
                    title: 'No goals yet',
                    message: 'Set your first life goal and track milestones',
                    icon: Icons.flag_outlined,
                    actionLabel: 'Create Goal',
                    onAction: () => context.push('${AppRoutes.home}/goals/create'),
                  ),
                _ => TabBarView(
                    controller: _tabController,
                    children: [
                      _GoalsListTab(goals: state.goals, onTap: _openGoal),
                      _CategoriesTab(byCategory: state.byCategory, onTap: _openGoal),
                      _TimelineTab(goals: state.goals, onTap: _openGoal),
                    ],
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openGoal(Goal goal) => context.push('${AppRoutes.home}/goals/${goal.id}');
}

class _GoalsListTab extends StatelessWidget {
  const _GoalsListTab({required this.goals, required this.onTap});

  final List<Goal> goals;
  final void Function(Goal) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: goals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _GoalListCard(goal: goals[index], onTap: () => onTap(goals[index]))
            .animate(delay: (index * 60).ms)
            .fadeIn(duration: theme.motion.entranceDuration, curve: theme.motion.entranceCurve)
            .slideX(begin: 0.05, duration: theme.motion.entranceDuration, curve: theme.motion.entranceCurve);
      },
    );
  }
}

/// Goals' own "premium goal card" — a progress ring, category/status row,
/// an animated milestone-dot strip, and days-remaining, in place of the
/// generic [ProgressCard] used by other screens.
class _GoalListCard extends StatelessWidget {
  const _GoalListCard({required this.goal, required this.onTap});

  final Goal goal;
  final VoidCallback onTap;

  Color get _color => Color(int.parse('FF${goal.colorHex}', radix: 16));

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0 && goal.status == GoalStatus.active;

    return GlassCard(
      useModuleTheme: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProgressRing(
                progress: goal.progress,
                size: 56,
                strokeWidth: 5,
                color: _color,
                child: Text(
                  '${(goal.progress * 100).round()}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(_categoryIcon(goal.category), size: 13, color: g.textMuted),
                        const SizedBox(width: 4),
                        Text(_categoryLabel(goal.category), style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 10),
                        Icon(_statusIcon(goal.status), size: 13, color: g.textMuted),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: g.textMuted),
            ],
          ),
          if (goal.milestones.isNotEmpty) ...[
            const SizedBox(height: 14),
            _MilestoneDots(milestones: goal.milestones, color: _color),
          ],
          const SizedBox(height: 10),
          Text(
            isOverdue ? '${-daysLeft} days overdue' : daysLeft >= 0 ? '$daysLeft days left' : 'Target date passed',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isOverdue ? AppColors.danger : g.textMuted),
          ),
        ],
      ),
    );
  }
}

/// A compact row of dots, one per milestone, filling in with the goal's
/// color as each is completed — the "Milestone widgets" / "Milestone
/// animations" the Goals module's design language calls for, without
/// duplicating the full milestone checklist that lives on the goal detail
/// screen.
class _MilestoneDots extends StatelessWidget {
  const _MilestoneDots({required this.milestones, required this.color});

  final List<GoalMilestone> milestones;
  final Color color;

  static const _maxShown = 8;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final shown = milestones.take(_maxShown).toList();
    final overflow = milestones.length - shown.length;

    return Row(
      children: [
        ...shown.map((m) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: m.isCompleted ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                builder: (_, t, __) => Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.lerp(g.chipFill, color, t),
                    border: Border.all(color: m.isCompleted ? color : g.border),
                  ),
                ),
              ),
            )),
        if (overflow > 0) Text('+$overflow', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: g.textMuted)),
      ],
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.byCategory, required this.onTap});

  final Map<GoalCategory, List<Goal>> byCategory;
  final void Function(Goal) onTap;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: byCategory.entries.map((entry) {
        final avgProgress = entry.value.fold<double>(0, (s, g) => s + g.progress) / entry.value.length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            useModuleTheme: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: g.chipFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: g.border),
                      ),
                      child: Icon(_categoryIcon(entry.key), color: theme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_categoryLabel(entry.key), style: Theme.of(context).textTheme.titleMedium),
                          Text('${entry.value.length} goals · ${(avgProgress * 100).round()}% avg', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    ProgressRing(progress: avgProgress, size: 44, strokeWidth: 4, color: theme.primary),
                  ],
                ),
                const SizedBox(height: 12),
                ...entry.value.map((goal) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: InkWell(
                        onTap: () => onTap(goal),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(goal.title, style: Theme.of(context).textTheme.bodyLarge)),
                              Text('${(goal.progress * 100).round()}%', style: Theme.of(context).textTheme.labelMedium),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right, size: 18, color: g.textMuted),
                            ],
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.goals, required this.onTap});

  final List<Goal> goals;
  final void Function(Goal) onTap;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final sorted = List<Goal>.from(goals)..sort((a, b) => a.targetDate.compareTo(b.targetDate));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final goal = sorted[index];
        final color = Color(int.parse('FF${goal.colorHex}', radix: 16));
        final isLast = index == sorted.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]),
                    ),
                    if (!isLast) Expanded(child: Container(width: 2, color: g.border)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GlassCard(
                    useModuleTheme: true,
                    onTap: () => onTap(goal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goalzy_date.DateUtils.formatShort(goal.targetDate), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
                        const SizedBox(height: 4),
                        Text(goal.title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(goal.description, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: goal.progress),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (_, value, __) => LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor: g.chipFill,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

IconData _categoryIcon(GoalCategory category) => switch (category) {
      GoalCategory.career => Icons.work_outline,
      GoalCategory.health => Icons.favorite_outline,
      GoalCategory.finance => Icons.account_balance_wallet_outlined,
      GoalCategory.learning => Icons.school_outlined,
      GoalCategory.personal => Icons.person_outline,
      GoalCategory.fitness => Icons.fitness_center,
      GoalCategory.other => Icons.category_outlined,
    };

IconData _statusIcon(GoalStatus status) => switch (status) {
      GoalStatus.active => Icons.trending_up,
      GoalStatus.completed => Icons.check_circle_outline,
      GoalStatus.paused => Icons.pause_circle_outline,
      GoalStatus.archived => Icons.archive_outlined,
    };
