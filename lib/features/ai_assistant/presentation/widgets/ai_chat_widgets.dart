import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../shared/domain/entities/ai_message.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/glass_input.dart';

/// A prompt users can tap to instantly ask GOALZY AI for a named,
/// recurring reflection — the "Morning Brief / Evening Reflection / Weekly
/// Review" concepts the brief calls for. These route through the exact
/// same `sendMessage` flow as any other suggestion; only the entry point
/// is new, not the underlying chat/response logic.
class AiQuickAction {
  const AiQuickAction({required this.icon, required this.label, required this.prompt});

  final IconData icon;
  final String label;
  final String prompt;
}

const aiQuickActions = [
  AiQuickAction(icon: Icons.wb_sunny_rounded, label: 'Morning Brief', prompt: 'Give me my morning brief for today'),
  AiQuickAction(icon: Icons.nightlight_round, label: 'Evening Reflection', prompt: 'Help me reflect on how today went'),
  AiQuickAction(icon: Icons.calendar_view_week_rounded, label: 'Weekly Review', prompt: 'Give me a review of this week'),
];

class AiMessageBubble extends StatelessWidget {
  const AiMessageBubble({super.key, required this.message});

  final AiMessage message;

  bool get _isUser => message.role == AiMessageRole.user;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;

    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(_isUser ? 16 : 4),
            bottomRight: Radius.circular(_isUser ? 4 : 16),
          ),
          gradient: _isUser ? theme.gradient : null,
          color: _isUser ? null : g.chipFill,
          border: Border.all(color: _isUser ? Colors.transparent : g.border),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: _isUser ? Colors.white : g.textPrimary, fontSize: 14, height: 1.4),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: _isUser ? 0.08 : -0.08, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
  }
}

class AiContextCardTile extends StatelessWidget {
  const AiContextCardTile({super.key, required this.card, this.onTap});

  final AiContextCard card;
  final VoidCallback? onTap;

  IconData get _icon => switch (card.type) {
        'goal' => Icons.flag_outlined,
        'habit' => Icons.repeat,
        'productivity' => Icons.bolt_outlined,
        _ => Icons.auto_awesome_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    return GlassCard(
      useModuleTheme: true,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 10),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon, size: 18, color: theme.primary),
            const SizedBox(height: 8),
            Text(card.title, style: Theme.of(context).textTheme.labelLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(card.subtitle, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

/// Compact card for the three named quick actions (Morning Brief / Evening
/// Reflection / Weekly Review) — a step up in visual weight from the
/// smaller [AiSuggestionChip]s, since these are first-class entry points
/// rather than generic suggestions.
class AiQuickActionCard extends StatelessWidget {
  const AiQuickActionCard({super.key, required this.action, required this.onTap});

  final AiQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    return GlassCard(
      useModuleTheme: true,
      onTap: onTap,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: SizedBox(
        width: 128,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, color: theme.primary, size: 20),
            const SizedBox(height: 10),
            Text(action.label, style: Theme.of(context).textTheme.labelLarge, maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class AiSuggestionChip extends StatefulWidget {
  const AiSuggestionChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<AiSuggestionChip> createState() => _AiSuggestionChipState();
}

class _AiSuggestionChipState extends State<AiSuggestionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: g.chipFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: g.border),
          ),
          child: Text(widget.label, style: Theme.of(context).textTheme.bodySmall),
        ),
      ),
    );
  }
}

class AiChatInputBar extends StatelessWidget {
  const AiChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
    this.showVoiceButton = true,
    this.onVoiceTap,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;
  final bool showVoiceButton;
  final VoidCallback? onVoiceTap;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;
    return GlassCard(
      useModuleTheme: true,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showVoiceButton)
            GestureDetector(
              onTap: isSending ? null : onVoiceTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: g.chipFill,
                  border: Border.all(color: g.border),
                ),
                child: Icon(
                  Icons.mic_none_rounded,
                  size: 22,
                  color: isSending ? g.textMuted : theme.primary,
                ),
              ),
            ),
          if (showVoiceButton) const SizedBox(width: 10),
          Expanded(
            child: GlassInput(
              controller: controller,
              hint: 'Ask GOALZY anything...',
              maxLines: 3,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSending ? null : theme.gradient,
                color: isSending ? g.chipFill : null,
              ),
              child: isSending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three pulsing dots, phase-offset so they animate in sequence — a
/// proper chat "typing" indicator instead of a generic spinner while the
/// AI composes a reply.
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    final g = GoalzyColors.of(context);
    final dotColor = theme.primary.withValues(alpha: 0.7);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: g.chipFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: g.border),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = (_controller.value - i * 0.2) % 1.0;
                final bump = (1 - (2 * t - 1).abs()).clamp(0.0, 1.0);
                final scale = 0.6 + 0.5 * bump;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
                  ),
                );
              }),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class AiChatBody extends StatelessWidget {
  const AiChatBody({
    super.key,
    required this.messages,
    required this.suggestions,
    required this.contextCards,
    required this.isSending,
    required this.onSuggestionTap,
    this.showContextCards = true,
    this.showSuggestions = true,
  });

  final List<AiMessage> messages;
  final List<String> suggestions;
  final List<AiContextCard> contextCards;
  final bool isSending;
  final ValueChanged<String> onSuggestionTap;
  final bool showContextCards;
  final bool showSuggestions;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (showContextCards && contextCards.isNotEmpty) ...[
          Text('Context', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: g.textSecondary)),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: contextCards.length,
              itemBuilder: (_, i) => AiContextCardTile(card: contextCards[i]),
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (messages.isEmpty && showSuggestions) ...[
          Text('Quick Actions', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: g.textSecondary)),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: aiQuickActions.length,
              itemBuilder: (_, i) => AiQuickActionCard(action: aiQuickActions[i], onTap: () => onSuggestionTap(aiQuickActions[i].prompt)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Suggestions', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: g.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            children: suggestions.map((s) => AiSuggestionChip(label: s, onTap: () => onSuggestionTap(s))).toList(),
          ),
          const SizedBox(height: 20),
        ],
        ...messages.map((m) => AiMessageBubble(message: m)),
        if (isSending) const _TypingIndicator(),
      ],
    );
  }
}
