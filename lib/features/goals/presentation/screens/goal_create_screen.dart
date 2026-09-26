import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/module_theme.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../shared/domain/entities/goal.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/glass_input.dart';
import '../../../../shared/widgets/components/module_background.dart';
import '../providers/goals_provider.dart';

/// Pushed as a standalone page outside the shell (see task_detail_screen
/// .dart's doc comment for why) — explicitly opted into the Goals module,
/// matching the detail screen it hands off to on save.
class GoalCreateScreen extends ConsumerStatefulWidget {
  const GoalCreateScreen({super.key});

  @override
  ConsumerState<GoalCreateScreen> createState() => _GoalCreateScreenState();
}

class _GoalCreateScreenState extends ConsumerState<GoalCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  GoalCategory _category = GoalCategory.personal;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 90));
  bool _isSaving = false;

  static const _categoryColors = {
    GoalCategory.career: '6D5DF6',
    GoalCategory.health: '00E396',
    GoalCategory.finance: 'FFB547',
    GoalCategory.learning: '00D4FF',
    GoalCategory.personal: 'FF6B81',
    GoalCategory.fitness: '00E396',
    GoalCategory.other: '94A3B8',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    // Previously forced `ColorScheme.dark(...)` with light-mode-only static
    // colors regardless of the app's actual theme — always rendering a
    // dark picker (and an inconsistent one, since the accent colors were
    // the light-mode values). Now just tints the *ambient* (already
    // correctly light/dark) color scheme with the module's own accent.
    final theme = context.moduleTheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: theme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final goal = Goal(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      targetDate: _targetDate,
      colorHex: _categoryColors[_category]!,
      createdAt: DateTime.now(),
    );

    await ref.read(goalsStateProvider.notifier).createGoal(goal);
    if (mounted) context.go('${AppRoutes.home}/goals/${goal.id}');
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScope(
      module: GoalzyModule.goals,
      child: Builder(
        builder: (context) {
          final theme = context.moduleTheme;
          final g = GoalzyColors.of(context);
          final motion = theme.motion;

          return Scaffold(
            backgroundColor: theme.background,
            body: Stack(
              children: [
                const Positioned.fill(child: ModuleBackground()),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
                            Expanded(child: Text('New Goal', style: Theme.of(context).textTheme.titleLarge)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                GlassCard(
                                  useModuleTheme: true,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GlassInput(
                                        controller: _titleController,
                                        label: 'Goal Title',
                                        hint: 'What do you want to achieve?',
                                        prefixIcon: Icons.flag_outlined,
                                        validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Title is required',
                                      ),
                                      const SizedBox(height: 16),
                                      GlassInput(
                                        controller: _descriptionController,
                                        label: 'Description',
                                        hint: 'Describe your goal and why it matters',
                                        prefixIcon: Icons.notes_outlined,
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: motion.entranceDuration, curve: motion.entranceCurve).slideY(begin: 0.06),
                                const SizedBox(height: 20),
                                Text('Category', style: Theme.of(context).textTheme.titleSmall),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: GoalCategory.values.map((cat) {
                                    final selected = _category == cat;
                                    final color = Color(int.parse('FF${_categoryColors[cat]}', radix: 16));
                                    return FilterChip(
                                      label: Text(_categoryLabel(cat)),
                                      selected: selected,
                                      onSelected: (_) => setState(() => _category = cat),
                                      avatar: Icon(_categoryIcon(cat), size: 16, color: selected ? color : g.textMuted),
                                      selectedColor: color.withValues(alpha: 0.25),
                                      checkmarkColor: color,
                                    );
                                  }).toList(),
                                ).animate(delay: 80.ms).fadeIn(duration: motion.entranceDuration, curve: motion.entranceCurve),
                                const SizedBox(height: 20),
                                Text('Target Date', style: Theme.of(context).textTheme.titleSmall),
                                const SizedBox(height: 12),
                                GlassCard(
                                  useModuleTheme: true,
                                  onTap: _pickDate,
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_month, color: AppColors.secondary),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ),
                                      Icon(Icons.chevron_right, color: g.textMuted),
                                    ],
                                  ),
                                ).animate(delay: 140.ms).fadeIn(duration: motion.entranceDuration, curve: motion.entranceCurve),
                                const SizedBox(height: 32),
                                GlassButton(
                                  label: 'Create Goal',
                                  icon: Icons.rocket_launch_outlined,
                                  expanded: true,
                                  isLoading: _isSaving,
                                  onPressed: _save,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
