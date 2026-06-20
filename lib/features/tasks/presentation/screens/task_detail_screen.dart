import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/domain/entities/task_item.dart';
import '../../../../shared/widgets/components/ai_orb.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../providers/tasks_provider.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksStateProvider);
    final task = tasksState.tasks.where((t) => t.id == taskId).firstOrNull;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          child: switch (true) {
            _ when tasksState.isLoading && task == null => const LoadingState(message: 'Loading task...'),
            _ when tasksState.error != null && task == null => ErrorState(message: tasksState.error!),
            _ when task == null => const EmptyState(title: 'Task not found', icon: Icons.task_outlined),
            _ => _TaskDetailBody(task: task),
          },
        ),
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
                        color: isCompleted ? AppColors.success.withValues(alpha: 0.2) : AppColors.glassFill,
                        border: Border.all(color: isCompleted ? AppColors.success : AppColors.glassBorder),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle_outlined,
                        color: isCompleted ? AppColors.success : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(task.description, style: Theme.of(context).textTheme.bodyLarge),
              ],
              const SizedBox(height: 24),
              GlassCard(
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.flag_outlined,
                      label: 'Priority',
                      value: _priorityLabel(task.priority),
                      valueColor: _priorityColor(task.priority),
                    ),
                    const Divider(color: AppColors.glassBorder, height: 24),
                    _DetailRow(
                      icon: Icons.info_outline,
                      label: 'Status',
                      value: _statusLabel(task.status),
                      valueColor: _statusColor(task.status),
                    ),
                    if (task.dueDate != null) ...[
                      const Divider(color: AppColors.glassBorder, height: 24),
                      _DetailRow(
                        icon: Icons.schedule,
                        label: 'Due Date',
                        value: goalzy_date.DateUtils.formatDate(task.dueDate!),
                        valueColor: task.isOverdue ? AppColors.danger : AppColors.textPrimary,
                      ),
                    ],
                    if (task.isRecurring) ...[
                      const Divider(color: AppColors.glassBorder, height: 24),
                      _DetailRow(
                        icon: Icons.repeat,
                        label: 'Recurrence',
                        value: task.recurrenceRule ?? 'Recurring',
                        valueColor: AppColors.warning,
                      ),
                    ],
                    if (linkedGoal != null) ...[
                      const Divider(color: AppColors.glassBorder, height: 24),
                      _DetailRow(
                        icon: Icons.track_changes,
                        label: 'Linked Goal',
                        value: linkedGoal.title,
                        valueColor: Color(int.parse('FF${linkedGoal.colorHex}', radix: 16)),
                      ),
                    ],
                  ],
                ),
              ),
              if (task.aiSuggestion != null) ...[
                const SizedBox(height: 20),
                Text('AI Insight', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                GlassCard(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary.withValues(alpha: 0.12), AppColors.glassFill],
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
                ),
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
                      selectedColor: _priorityColor(priority).withValues(alpha: 0.25),
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
        Icon(icon, size: 20, color: AppColors.textMuted),
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

Color _priorityColor(TaskPriority priority) => switch (priority) {
      TaskPriority.low => AppColors.textMuted,
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

Color _statusColor(TaskStatus status) => switch (status) {
      TaskStatus.pending => AppColors.textMuted,
      TaskStatus.inProgress => AppColors.secondary,
      TaskStatus.completed => AppColors.success,
      TaskStatus.cancelled => AppColors.danger,
    };
