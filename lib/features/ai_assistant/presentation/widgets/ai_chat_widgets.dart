import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/domain/entities/ai_message.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/glass_input.dart';

class AiMessageBubble extends StatelessWidget {
  const AiMessageBubble({super.key, required this.message});

  final AiMessage message;

  bool get _isUser => message.role == AiMessageRole.user;

  @override
  Widget build(BuildContext context) {
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
          gradient: _isUser
              ? AppColors.primaryGradient
              : LinearGradient(colors: [AppColors.surfaceLight, AppColors.glassFill]),
          border: Border.all(color: _isUser ? Colors.transparent : AppColors.glassBorder),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: _isUser ? Colors.white : AppColors.textPrimary, fontSize: 14, height: 1.4),
        ),
      ),
    );
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
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 10),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon, size: 18, color: AppColors.secondary),
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

class AiSuggestionChip extends StatelessWidget {
  const AiSuggestionChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
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
    return GlassCard(
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
                  color: AppColors.glassFill,
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Icon(
                  Icons.mic_none_rounded,
                  size: 22,
                  color: isSending ? AppColors.textMuted : AppColors.secondary,
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
                gradient: isSending ? null : AppColors.primaryGradient,
                color: isSending ? AppColors.glassFill : null,
              ),
              child: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (showContextCards && contextCards.isNotEmpty) ...[
          Text('Context', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary)),
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
          Text('Suggestions', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            children: suggestions.map((s) => AiSuggestionChip(label: s, onTap: () => onSuggestionTap(s))).toList(),
          ),
          const SizedBox(height: 20),
        ],
        ...messages.map((m) => AiMessageBubble(message: m)),
        if (isSending)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}
