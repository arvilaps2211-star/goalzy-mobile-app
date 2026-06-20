import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/domain/entities/task_item.dart';
import '../../../../shared/widgets/components/ai_orb.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../providers/tasks_provider.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  TaskPriority? _filterPriority;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksStateProvider);
    var tasks = state.pending;
    if (_filterPriority != null) {
      tasks = tasks.where((t) => t.priority == _filterPriority).toList();
    }

    final today = tasks.where((t) => t.dueDate != null && goalzy_date.DateUtils.isSameDay(t.dueDate!, DateTime.now())).toList();
    final upcoming = tasks.where((t) => t.dueDate != null && t.dueDate!.isAfter(DateTime.now()) && !goalzy_date.DateUtils.isSameDay(t.dueDate!, DateTime.now())).toList();
    final overdue = tasks.where((t) => t.isOverdue).toList();
    final noDue = tasks.where((t) => t.dueDate == null).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tasks', style: Theme.of(context).textTheme.headlineMedium),
                    Text(
                      '${state.pending.length} pending · ${state.completed.length} done',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _PriorityChip(label: 'All', selected: _filterPriority == null, color: AppColors.primary, onTap: () => setState(() => _filterPriority = null)),
                    ...TaskPriority.values.map((p) => _PriorityChip(
                          label: _priorityLabel(p),
                          selected: _filterPriority == p,
                          color: _priorityColor(p),
                          onTap: () => setState(() => _filterPriority = p),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: switch (true) {
                  _ when state.isLoading => const LoadingState(message: 'Loading tasks...'),
                  _ when state.error != null => ErrorState(message: state.error!, onRetry: () => ref.read(tasksStateProvider.notifier).loadTasks()),
                  _ when state.tasks.isEmpty => const EmptyState(title: 'No tasks', message: 'Your task list is clear', icon: Icons.task_alt),
                  _ => RefreshIndicator(
                      onRefresh: () => ref.read(tasksStateProvider.notifier).loadTasks(),
                      color: AppColors.primary,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          if (state.withAiSuggestions.isNotEmpty) ...[
                            _SectionHeader(title: 'AI Suggestions', icon: Icons.auto_awesome, color: AppColors.secondary),
                            const SizedBox(height: 8),
                            ...state.withAiSuggestions.map((t) => _AiSuggestionCard(task: t, onTap: () => _openTask(t))),
                            const SizedBox(height: 20),
                          ],
                          if (overdue.isNotEmpty) ...[
                            _SectionHeader(title: 'Overdue', icon: Icons.warning_amber, color: AppColors.danger),
                            const SizedBox(height: 8),
                            ...overdue.map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t))),
                            const SizedBox(height: 20),
                          ],
                          if (today.isNotEmpty) ...[
                            _SectionHeader(title: 'Today', icon: Icons.today, color: AppColors.primary),
                            const SizedBox(height: 8),
                            ...today.map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t))),
                            const SizedBox(height: 20),
                          ],
                          if (upcoming.isNotEmpty) ...[
                            _SectionHeader(title: 'Upcoming', icon: Icons.upcoming, color: AppColors.secondary),
                            const SizedBox(height: 8),
                            ...upcoming.map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t))),
                            const SizedBox(height: 20),
                          ],
                          if (state.recurring.isNotEmpty) ...[
                            _SectionHeader(title: 'Recurring', icon: Icons.repeat, color: AppColors.warning),
                            const SizedBox(height: 8),
                            ...state.recurring.map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t))),
                            const SizedBox(height: 20),
                          ],
                          if (noDue.isNotEmpty) ...[
                            _SectionHeader(title: 'No Due Date', icon: Icons.inbox_outlined, color: AppColors.textMuted),
                            const SizedBox(height: 8),
                            ...noDue.map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t))),
                          ],
                          if (state.completed.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _SectionHeader(title: 'Completed', icon: Icons.check_circle_outline, color: AppColors.success),
                            const SizedBox(height: 8),
                            ...state.completed.take(5).map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t), completed: true)),
                          ],
                        ],
                      ),
                    ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTask(TaskItem task) => context.push('${AppRoutes.home}/tasks/${task.id}');
  void _toggle(TaskItem task) => ref.read(tasksStateProvider.notifier).toggleComplete(task.id);
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon, required this.color});

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
      ],
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.label, required this.selected, required this.color, required this.onTap});

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: color.withValues(alpha: 0.25),
        checkmarkColor: color,
        side: BorderSide(color: selected ? color : AppColors.glassBorder),
      ),
    );
  }
}

class _AiSuggestionCard extends StatelessWidget {
  const _AiSuggestionCard({required this.task, required this.onTap});

  final TaskItem task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: onTap,
        gradient: LinearGradient(
          colors: [AppColors.secondary.withValues(alpha: 0.12), AppColors.glassFill],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AIOrb(size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(task.aiSuggestion!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.secondary)),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn().shimmer(duration: 2.seconds, color: AppColors.secondary.withValues(alpha: 0.1)),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onTap, required this.onToggle, this.completed = false});

  final TaskItem task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(task.priority);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                completed || task.status == TaskStatus.completed ? Icons.check_circle : Icons.circle_outlined,
                color: completed || task.status == TaskStatus.completed ? AppColors.success : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          decoration: completed ? TextDecoration.lineThrough : null,
                          color: completed ? AppColors.textMuted : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _Badge(label: _priorityLabel(task.priority), color: priorityColor),
                      if (task.dueDate != null)
                        _Badge(
                          label: task.isOverdue ? 'Overdue' : goalzy_date.DateUtils.formatRelative(task.dueDate!),
                          color: task.isOverdue ? AppColors.danger : AppColors.textMuted,
                          icon: Icons.schedule,
                        ),
                      if (task.isRecurring) const _Badge(label: 'Recurring', color: AppColors.warning, icon: Icons.repeat),
                      if (task.status == TaskStatus.inProgress) const _Badge(label: 'In Progress', color: AppColors.secondary),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 10, color: color), const SizedBox(width: 4)],
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
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
