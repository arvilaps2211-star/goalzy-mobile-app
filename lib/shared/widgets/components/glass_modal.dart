import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Premium blurred-backdrop bottom sheet with an iOS-style drag handle.
///
/// Colors previously came from static [AppColors] (light palette only,
/// wrong in dark mode) — now sourced from [GoalzyColors] so the sheet
/// matches the active theme.
class GlassModal extends StatelessWidget {
  const GlassModal({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    List<Widget>? actions,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassModal(title: title, actions: actions, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: g.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: g.border),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: g.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: g.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
              if (actions != null) ...[
                const SizedBox(height: 20),
                Row(children: actions!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
