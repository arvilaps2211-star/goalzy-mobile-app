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
    final (bg, fg, border) = switch (variant) {
      GlassButtonVariant.primary => (null, Colors.white, Colors.transparent),
      GlassButtonVariant.secondary => (AppColors.glassFill, AppColors.secondary, AppColors.glassBorder),
      GlassButtonVariant.ghost => (Colors.transparent, AppColors.textPrimary, AppColors.glassBorder),
      GlassButtonVariant.danger => (AppColors.danger.withValues(alpha: 0.2), AppColors.danger, AppColors.danger.withValues(alpha: 0.3)),
    };

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: variant == GlassButtonVariant.primary ? AppColors.primaryGradient : null,
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate(onPlay: (c) => c.stop()).shimmer(duration: isLoading ? 1200.ms : 0.ms);

    if (expanded) button = SizedBox(width: double.infinity, child: button);
    return button;
  }
}
