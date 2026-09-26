import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/module_theme.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/domain/entities/task_item.dart';
import '../../../../shared/widgets/components/ai_orb.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/module_background.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../providers/tasks_provider.dart';

/// Pushed as a standalone page (see app_router.dart — `tasks/:id` is a
/// plain nested GoRoute, not a ShellRoute child), so — like Login/Splash —
/// it never automatically gets a module scope the way tabbed screens do
/// via MainShell. Explicitly opted into the Tasks module here, unlike
/// Login/Splash's Dashboard choice, since this page is unambiguously a
/// Tasks detail view, not app-wide chrome.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksStateProvider);
    final task = tasksState.tasks.where((t) => t.id == taskId).firstOrNull;

    return ModuleScope(
      module: GoalzyModule.tasks,
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
                    _ when tasksState.isLoading && task == null => const LoadingState(message: 'Loading task...'),
                    _ when tasksState.error != null && task == null => ErrorState(message: tasksState.error!),
                    _ when task == null => const EmptyState(title: 'Task not found', icon: Icons.task_outlined),
                    _ => _TaskDetailBody(task: task),
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

class _TaskDetailBody extends ConsumerWidget {
  const _TaskDetailBody({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsStateProvider).goals;
    final linkedGoal = task.goalId != null ? goals.where((g) => g.id == task.goalId).firstOrNull : null;
    final isCompleted = task.status == TaskStatus.completed;
    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;

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
                await ref.read(tasksStateProvider.notifier).deleteTask(task.id);
                if (context.mounted) context.pop();
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  GestureDetector(
                    onTap: () => ref.read(tasksStateProvider.notifier).toggleComplete(task.id),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? AppColors.success.withValues(alpha: 0.2) : g.chipFill,
                        border: Border.all(color: isCompleted ? AppColors.success : g.border),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle_outlined,
                        color: isCompleted ? AppColors.success : g.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? g.textMuted : g.textPrimary,
                          ),
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: 0.08),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(task.description, style: Theme.of(context).textTheme.bodyLarge),
              ],
              const SizedBox(height: 24),
              GlassCard(
                useModuleTheme: true,
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.flag_outlined,
                      label: 'Priority',
                      value: _priorityLabel(task.priority),
                      valueColor: _priorityColor(context, task.priority),
                    ),
                    Divider(color: g.border, height: 24),
                    _DetailRow(
                      icon: Icons.info_outline,
                      label: 'Status',
                      value: _statusLabel(task.status),
                      valueColor: _statusColor(context, task.status),
                    ),
                    if (task.dueDate != null) ...[
                      Divider(color: g.border, height: 24),
                      _DetailRow(
                        icon: Icons.schedule,
                        label: 'Due Date',
                        value: goalzy_date.DateUtils.formatDate(task.dueDate!),
                        valueColor: task.isOverdue ? AppColors.danger : g.textPrimary,
                      ),
                    ],
                    if (task.isRecurring) ...[
                      Divider(color: g.border, height: 24),
                      _DetailRow(
                        icon: Icons.repeat,
                        label: 'Recurrence',
                        value: task.recurrenceRule ?? 'Recurring',
                        valueColor: AppColors.warning,
                      ),
                    ],
                    if (linkedGoal != null) ...[
                      Divider(color: g.border, height: 24),
                      _DetailRow(
                        icon: Icons.track_changes,
                        label: 'Linked Goal',
                        value: linkedGoal.title,
                        valueColor: Color(int.parse('FF${linkedGoal.colorHex}', radix: 16)),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.06),
              if (task.aiSuggestion != null) ...[
                const SizedBox(height: 20),
                Text('AI Insight', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                GlassCard(
                  useModuleTheme: true,
                  gradient: LinearGradient(
                    colors: [AppColors.secondary.withValues(alpha: 0.12), g.chipFill],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AIOrb(size: 40),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(task.aiSuggestion!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondary)),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 140.ms),
              ],
              const SizedBox(height: 24),
              if (!isCompleted) ...[
                Text('Update Status', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    TaskStatus.pending,
                    TaskStatus.inProgress,
                    TaskStatus.completed,
                  ].map((status) {
                    final selected = task.status == status;
                    return FilterChip(
                      label: Text(_statusLabel(status)),
                      selected: selected,
                      selectedColor: theme.primary.withValues(alpha: 0.22),
                      onSelected: (_) => ref.read(tasksStateProvider.notifier).updateTask(task.copyWith(status: status)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Change Priority', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: TaskPriority.values.map((priority) {
                    final selected = task.priority == priority;
                    return FilterChip(
                      label: Text(_priorityLabel(priority)),
                      selected: selected,
                      onSelected: (_) => ref.read(tasksStateProvider.notifier).updateTask(task.copyWith(priority: priority)),
                      selectedColor: _priorityColor(context, priority).withValues(alpha: 0.25),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              GlassButton(
                label: isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                expanded: true,
                icon: isCompleted ? Icons.undo : Icons.check,
                onPressed: () => ref.read(tasksStateProvider.notifier).toggleComplete(task.id),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value, required this.valueColor});

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: GoalzyColors.of(context).textMuted),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: valueColor)),
      ],
    );
  }
}

String _priorityLabel(TaskPriority priority) => switch (priority) {
      TaskPriority.low => 'Low',
      TaskPriority.medium => 'Medium',
      TaskPriority.high => 'High',
      TaskPriority.urgent => 'Urgent',
    };

Color _priorityColor(BuildContext context, TaskPriority priority) => switch (priority) {
      TaskPriority.low => GoalzyColors.of(context).textMuted,
      TaskPriority.medium => AppColors.secondary,
      TaskPriority.high => AppColors.warning,
      TaskPriority.urgent => AppColors.danger,
    };

String _statusLabel(TaskStatus status) => switch (status) {
      TaskStatus.pending => 'Pending',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.completed => 'Completed',
      TaskStatus.cancelled => 'Cancelled',
    };

Color _statusColor(BuildContext context, TaskStatus status) => switch (status) {
      TaskStatus.pending => GoalzyColors.of(context).textMuted,
      TaskStatus.inProgress => AppColors.secondary,
      TaskStatus.completed => AppColors.success,
      TaskStatus.cancelled => AppColors.danger,
    };
