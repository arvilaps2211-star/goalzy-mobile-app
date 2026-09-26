import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Themed text field wrapper with a subtle focus glow.
///
/// Border/fill styling comes from the global [InputDecorationTheme] (see
/// core/theme/app_theme.dart) — this widget layers the label, focus glow,
/// and dark-mode-correct text/icon tinting on top of that. Previously the
/// text style and prefix-icon color were hardcoded to the light palette
/// and didn't adapt in dark mode; both now read from [GoalzyColors].
class GlassInput extends StatefulWidget {
  const GlassInput({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  /// Optional external focus node. When omitted, one is created and
  /// managed internally.
  final FocusNode? focusNode;

  @override
  State<GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<GlassInput> {
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _focused
                ? [BoxShadow(color: g.primary.withValues(alpha: 0.12), blurRadius: 14, offset: const Offset(0, 4))]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            validator: widget.validator,
            style: TextStyle(color: g.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: _focused ? g.primary : g.textMuted, size: 20)
                  : null,
              suffixIcon: widget.suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
