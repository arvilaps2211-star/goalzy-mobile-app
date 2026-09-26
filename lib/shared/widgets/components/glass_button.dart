import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/haptics.dart';

enum GlassButtonVariant { primary, secondary, ghost, danger }

/// Premium rounded button with a real tap-depth press interaction — scales
/// down while held and springs back on release, and flattens its shadow
/// while pressed for an extra sense of physical depth.
class GlassButton extends StatefulWidget {
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
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);

    final (bg, fg, border) = switch (widget.variant) {
      GlassButtonVariant.primary => (g.primary, Colors.white, Colors.transparent),
      GlassButtonVariant.secondary => (g.chipFill, g.primary, g.border),
      GlassButtonVariant.ghost => (Colors.transparent, g.textPrimary, g.border),
      GlassButtonVariant.danger => (
          AppColors.danger.withValues(alpha: 0.1),
          AppColors.danger,
          AppColors.danger.withValues(alpha: 0.2),
        ),
    };

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onPressed,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: widget.variant == GlassButtonVariant.primary ? null : Border.all(color: border),
            boxShadow: widget.variant == GlassButtonVariant.primary && !_pressed
                ? [BoxShadow(color: g.primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            child: Row(
              mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
                else ...[
                  if (widget.icon != null) ...[Icon(widget.icon, size: 18, color: fg), const SizedBox(width: 8)],
                  Text(widget.label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.expanded) button = SizedBox(width: double.infinity, child: button);

    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: button,
    );
  }
}
