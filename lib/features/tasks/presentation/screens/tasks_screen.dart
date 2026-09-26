import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/domain/entities/task_item.dart';
import '../../../../shared/widgets/components/ai_orb.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/glass_input.dart';
import '../../../../shared/widgets/components/glass_modal.dart';
import '../../../../shared/widgets/components/section_header.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../providers/tasks_provider.dart';

/// Tasks — action, productivity, speed (see core/theme/module_theme.dart
/// for the Tasks module identity: sky blue, dotted-grid backdrop, fast
/// snappy motion). Grouping/filtering logic is unchanged from before;
/// this pass adds swipe actions, animated completion, a morphing
/// quick-add FAB, and fixes several colors that were hardcoded to the
/// light palette and didn't adapt in dark mode.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  TaskPriority? _filterPriority;
  final _scrollController = ScrollController();
  bool _fabExtended = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _fabExtended) {
      setState(() => _fabExtended = false);
    } else if (direction == ScrollDirection.forward && !_fabExtended) {
      setState(() => _fabExtended = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksStateProvider);
    final theme = context.moduleTheme;
    var tasks = state.pending;
    if (_filterPriority != null) {
      tasks = tasks.where((t) => t.priority == _filterPriority).toList();
    }

    final today = tasks.where((t) => t.dueDate != null && goalzy_date.DateUtils.isSameDay(t.dueDate!, DateTime.now())).toList();
    final upcoming = tasks.where((t) => t.dueDate != null && t.dueDate!.isAfter(DateTime.now()) && !goalzy_date.DateUtils.isSameDay(t.dueDate!, DateTime.now())).toList();
    final overdue = tasks.where((t) => t.isOverdue).toList();
    final noDue = tasks.where((t) => t.dueDate == null).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _MorphingFab(
        extended: _fabExtended,
        onTap: () => _showQuickAdd(context),
      ),
      body: SafeArea(
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
                  _PriorityChip(label: 'All', selected: _filterPriority == null, color: theme.primary, onTap: () => setState(() => _filterPriority = null)),
                  ...TaskPriority.values.map((p) => _PriorityChip(
                        label: _priorityLabel(p),
                        selected: _filterPriority == p,
                        color: _priorityColor(context, p),
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
                    color: theme.primary,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      children: [
                        if (state.withAiSuggestions.isNotEmpty) ...[
                          SectionHeader(title: 'AI Suggestions', icon: Icons.auto_awesome, accentColor: AppColors.secondary),
                          ...state.withAiSuggestions.map((t) => _AiSuggestionCard(task: t, onTap: () => _openTask(t))),
                          const SizedBox(height: 12),
                        ],
                        if (overdue.isNotEmpty) ...[
                          SectionHeader(title: 'Overdue', icon: Icons.warning_amber_rounded, accentColor: AppColors.danger),
                          ...overdue.map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t), onDelete: () => _delete(t))),
                          const SizedBox(height: 12),
                        ],
                        if (today.isNotEmpty) ...[
                          SectionHeader(title: 'Today', icon: Icons.today_rounded, accentColor: theme.primary),
                          ...today.map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t), onDelete: () => _delete(t))),
                          const SizedBox(height: 12),
                        ],
                        if (upcoming.isNotEmpty) ...[
                          SectionHeader(title: 'Upcoming', icon: Icons.upcoming_rounded, accentColor: theme.accent),
                          ...upcoming.map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t), onDelete: () => _delete(t))),
                          const SizedBox(height: 12),
                        ],
                        if (state.recurring.isNotEmpty) ...[
                          SectionHeader(title: 'Recurring', icon: Icons.repeat_rounded, accentColor: AppColors.warning),
                          ...state.recurring.map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t), onDelete: () => _delete(t))),
                          const SizedBox(height: 12),
                        ],
                        if (noDue.isNotEmpty) ...[
                          SectionHeader(title: 'No Due Date', icon: Icons.inbox_outlined, accentColor: GoalzyColors.of(context).textMuted),
                          ...noDue.map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t), onDelete: () => _delete(t))),
                        ],
                        if (state.completed.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SectionHeader(title: 'Completed', icon: Icons.check_circle_outline_rounded, accentColor: AppColors.success),
                          ...state.completed.take(5).map((t) => _TaskTile(task: t, onTap: () => _openTask(t), onToggle: () => _toggle(t), onDelete: () => _delete(t), completed: true)),
                        ],
                      ],
                    ),
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openTask(TaskItem task) => context.push('${AppRoutes.home}/tasks/${task.id}');
  void _toggle(TaskItem task) {
    HapticFeedback.lightImpact();
    ref.read(tasksStateProvider.notifier).toggleComplete(task.id);
  }
  void _delete(TaskItem task) => ref.read(tasksStateProvider.notifier).deleteTask(task.id);

  Future<void> _showQuickAdd(BuildContext context) async {
    final controller = TextEditingController();
    var priority = TaskPriority.medium;

    try {
      await GlassModal.show(
        context,
        title: 'New Task',
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassInput(
                  controller: controller,
                  label: 'Title',
                  hint: 'What do you need to do?',
                  onChanged: (_) => setModalState(() {}),
                ),
                const SizedBox(height: 16),
                Text('Priority', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TaskPriority.values.map((p) {
                    final color = _priorityColor(context, p);
                    return ChoiceChip(
                      label: Text(_priorityLabel(p)),
                      selected: priority == p,
                      onSelected: (_) => setModalState(() => priority = p),
                      selectedColor: color.withValues(alpha: 0.22),
                      labelStyle: TextStyle(color: priority == p ? color : null, fontWeight: FontWeight.w600),
                      side: BorderSide(color: priority == p ? color : GoalzyColors.of(context).border),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                GlassButton(
                  label: 'Add Task',
                  icon: Icons.add_task_rounded,
                  expanded: true,
                  onPressed: controller.text.trim().isEmpty
                      ? null
                      : () {
                          ref.read(tasksStateProvider.notifier).createTask(
                                TaskItem(
                                  id: const Uuid().v4(),
                                  title: controller.text.trim(),
                                  priority: priority,
                                  dueDate: DateTime.now(),
                                ),
                              );
                          Navigator.pop(context);
                        },
                ),
              ],
            );
          },
        ),
      );
    } finally {
      controller.dispose();
    }
  }
}

/// Compact pill FAB that collapses to icon-only while the list is being
/// scrolled and expands back to its labelled form at rest — the "FAB
/// morphing" motion called for by the Tasks module's design language.
/// Uses [AnimatedSize] (rather than a manually animated width) so the
/// content is always laid out at its natural size — no risk of the label
/// overflowing a container that hasn't finished growing yet.
class _MorphingFab extends StatelessWidget {
  const _MorphingFab({required this.extended, required this.onTap});

  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    final radius = extended ? 20.0 : 28.0;

    return Material(
      color: theme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      elevation: 6,
      shadowColor: theme.primary.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: Padding(
            padding: extended ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16) : const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white),
                if (extended) ...[
                  const SizedBox(width: 8),
                  const Text('New Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
        ),
      ),
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
    final g = GoalzyColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: color.withValues(alpha: 0.25),
        checkmarkColor: color,
        side: BorderSide(color: selected ? color : g.border),
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
        useModuleTheme: true,
        onTap: onTap,
        gradient: LinearGradient(
          colors: [AppColors.secondary.withValues(alpha: 0.14), GoalzyColors.of(context).chipFill],
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
  const _TaskTile({
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
    this.completed = false,
  });

  final TaskItem task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final isDone = completed || task.status == TaskStatus.completed;
    final priorityColor = _priorityColor(context, task.priority);

    return Dismissible(
      key: ValueKey(task.id),
      direction: isDone ? DismissDirection.endToStart : DismissDirection.horizontal,
      background: _SwipeBackground(alignment: Alignment.centerLeft, color: AppColors.success, icon: Icons.check_circle_rounded, label: 'Complete'),
      secondaryBackground: _SwipeBackground(alignment: Alignment.centerRight, color: AppColors.danger, icon: Icons.delete_rounded, label: 'Delete'),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          return false;
        }
        return true;
      },
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          useModuleTheme: true,
          onTap: onTap,
          child: Row(
            children: [
              _AnimatedCheckIcon(completed: isDone, onTap: onToggle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? g.textMuted : g.textPrimary,
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
                            color: task.isOverdue ? AppColors.danger : g.textMuted,
                            icon: Icons.schedule,
                          ),
                        if (task.isRecurring) const _Badge(label: 'Recurring', color: AppColors.warning, icon: Icons.repeat),
                        if (task.status == TaskStatus.inProgress) const _Badge(label: 'In Progress', color: AppColors.secondary),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: g.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Revealed behind a [_TaskTile] as it's swiped — green "Complete" to the
/// left, red "Delete" to the right.
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.alignment, required this.color, required this.icon, required this.label});

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: color),
          if (alignment == Alignment.centerLeft) ...[
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}

/// Checkbox with a real "pop" on completion instead of an instant icon
/// swap — scales up past 1x and springs back, color-lerping to success
/// green, matching the Tasks module's "Checkbox morph" motion language.
class _AnimatedCheckIcon extends StatefulWidget {
  const _AnimatedCheckIcon({required this.completed, required this.onTap});

  final bool completed;
  final VoidCallback onTap;

  @override
  State<_AnimatedCheckIcon> createState() => _AnimatedCheckIconState();
}

class _AnimatedCheckIconState extends State<_AnimatedCheckIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: widget.completed ? 1 : 0,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)), weight: 60),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant _AnimatedCheckIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completed != oldWidget.completed) {
      widget.completed ? _controller.forward(from: 0) : _controller.reverse(from: 1);
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Transform.scale(
          scale: _scale.value,
          child: Icon(
            widget.completed ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: Color.lerp(g.textMuted, AppColors.success, _controller.value),
          ),
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

Color _priorityColor(BuildContext context, TaskPriority priority) => switch (priority) {
      TaskPriority.low => GoalzyColors.of(context).textMuted,
      TaskPriority.medium => AppColors.secondary,
      TaskPriority.high => AppColors.warning,
      TaskPriority.urgent => AppColors.danger,
    };
