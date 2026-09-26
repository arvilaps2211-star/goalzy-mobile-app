import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/module_theme.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/module_background.dart';
import '../../../../shared/widgets/components/progress_ring.dart';
import '../../../../shared/widgets/components/stat_card.dart';
import '../providers/focus_provider.dart';

/// Focus Mode — deep work, silence, presence (see core/theme/module_theme
/// .dart: violet-purple, radial-glow backdrop, "breathing" motion). This
/// is a net-new feature, not a redesign of something that existed — the
/// brief calls for it explicitly ("Large focus timer, Session statistics,
/// Focus ring, Minimal distractions") but no Focus screen, provider, or
/// entity existed anywhere in the app before this milestone.
///
/// Pushed as a standalone page (see task_detail_screen.dart's doc comment
/// on why standalone pages don't get a module scope automatically) —
/// which conveniently also serves "minimal distractions" for free, since
/// it means no bottom nav or tab chrome is visible while focusing.
class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScope(
      module: GoalzyModule.focus,
      child: Builder(
        builder: (context) {
          final theme = context.moduleTheme;
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
                          ],
                        ),
                      ),
                      const Expanded(child: _FocusBody()),
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

class _FocusBody extends ConsumerWidget {
  const _FocusBody();

  static const _presets = [25, 50, 90];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(focusStateProvider);
    final notifier = ref.read(focusStateProvider.notifier);
    final theme = context.moduleTheme;

    final isRunning = state.status == FocusTimerStatus.running;
    final isPaused = state.status == FocusTimerStatus.paused;
    final isCompleted = state.status == FocusTimerStatus.completed;
    final isIdle = state.status == FocusTimerStatus.idle;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            isCompleted
                ? 'Session complete'
                : isRunning
                    ? 'Stay focused'
                    : isPaused
                        ? 'Paused'
                        : 'Ready when you are',
            style: Theme.of(context).textTheme.titleMedium,
          ).animate().fadeIn(duration: theme.motion.entranceDuration, curve: theme.motion.entranceCurve),
          const SizedBox(height: 32),
          SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _BreathingGlow(active: isRunning, color: theme.primary),
                ProgressRing(
                  progress: isCompleted ? 1.0 : state.progress,
                  size: 240,
                  strokeWidth: 10,
                  color: theme.primary,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isCompleted ? '🎉' : _formatTime(state.remainingSeconds),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (!isCompleted)
                        Text('${state.totalSeconds ~/ 60} min session', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (isIdle) ...[
            Text('Duration', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.center,
              children: _presets.map((m) {
                final selected = state.totalSeconds == m * 60;
                return ChoiceChip(
                  label: Text('$m min'),
                  selected: selected,
                  onSelected: (_) => notifier.setDuration(m),
                  selectedColor: theme.primary.withValues(alpha: 0.22),
                  labelStyle: TextStyle(color: selected ? theme.primary : null, fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
          ],
          if (isCompleted)
            GlassButton(
              label: 'Start New Session',
              expanded: true,
              icon: Icons.refresh_rounded,
              onPressed: notifier.reset,
            )
          else
            Row(
              children: [
                if (isRunning || isPaused) ...[
                  Expanded(
                    child: GlassButton(
                      label: 'Reset',
                      variant: GlassButtonVariant.secondary,
                      onPressed: notifier.reset,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: isRunning || isPaused ? 2 : 1,
                  child: GlassButton(
                    label: isRunning ? 'Pause' : (isPaused ? 'Resume' : 'Start Focus'),
                    icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    onPressed: isRunning ? notifier.pause : notifier.start,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Focus Today',
                  value: state.todayMinutes,
                  valueSuffix: 'min',
                  icon: Icons.timer_outlined,
                  useModuleTheme: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Sessions Today',
                  value: state.todaySessionCount,
                  icon: Icons.check_circle_outline,
                  useModuleTheme: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Slow ambient pulse behind the timer ring while a session is running —
/// the "breathing animation" the Focus module's design language calls
/// for. Sits idle (static, low-opacity) when not running rather than
/// disappearing entirely, so the layout doesn't jump.
class _BreathingGlow extends StatefulWidget {
  const _BreathingGlow({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  State<_BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<_BreathingGlow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000));
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _BreathingGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final scale = widget.active ? 0.94 + 0.12 * t : 1.0;
        final opacity = widget.active ? 0.22 + 0.18 * t : 0.14;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [widget.color.withValues(alpha: opacity), widget.color.withValues(alpha: 0)],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _formatTime(int totalSeconds) {
  final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final s = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
