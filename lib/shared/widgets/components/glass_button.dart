import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

enum GlassButtonVariant { primary, secondary, ghost, danger }

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = GlassButtonVariant.primary,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final GlassButtonVariant variant;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);

    final (bg, fg, border) = switch (variant) {
      GlassButtonVariant.primary => (g.primary, Colors.white, Colors.transparent),
      GlassButtonVariant.secondary => (g.chipFill, g.primary, g.border),
      GlassButtonVariant.ghost => (Colors.transparent, g.textPrimary, g.border),
      GlassButtonVariant.danger => (AppColors.danger.withValues(alpha: 0.1), AppColors.danger, AppColors.danger.withValues(alpha: 0.2)),
    };

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: variant == GlassButtonVariant.primary ? null : Border.all(color: border),
            boxShadow: variant == GlassButtonVariant.primary
                ? [BoxShadow(color: g.primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            child: Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
                else ...[
                  if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 8)],
                  Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (expanded) button = SizedBox(width: double.infinity, child: button);
    return button.animate(onPlay: (c) => c.stop()).scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
          duration: 200.ms,
          curve: Curves.easeOutBack,
        );
  }
}
