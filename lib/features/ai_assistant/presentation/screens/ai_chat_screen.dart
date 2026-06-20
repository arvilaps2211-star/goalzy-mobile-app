import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/components/ai_orb.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_chat_widgets.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final message = text ?? _controller.text;
    if (message.trim().isEmpty) return;
    _controller.clear();
    await ref.read(aiStateProvider.notifier).sendMessage(message);
    if (_scrollController.hasClients) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    const AIOrb(size: 40, pulse: false),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GOALZY AI', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            state.isSending ? 'Thinking...' : 'Online',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: state.isSending ? AppColors.warning : AppColors.success,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: 'Clear chat',
                      onPressed: state.messages.isEmpty ? null : () => ref.read(aiStateProvider.notifier).clearChat(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.glassBorder),
              Expanded(
                child: state.isLoading
                    ? const LoadingState(message: 'Loading conversation...')
                    : state.error != null && state.messages.isEmpty
                        ? ErrorState(
                            message: state.error!,
                            onRetry: () => ref.invalidate(aiStateProvider),
                          )
                        : SingleChildScrollView(
                            controller: _scrollController,
                            child: AiChatBody(
                              messages: state.messages,
                              suggestions: state.suggestions,
                              contextCards: state.contextCards,
                              isSending: state.isSending,
                              onSuggestionTap: _send,
                              showSuggestions: state.messages.isEmpty,
                            ),
                          ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: AiChatInputBar(
                  controller: _controller,
                  isSending: state.isSending,
                  onSend: () => _send(),
                  onVoiceTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voice input coming soon'),
                        backgroundColor: AppColors.surfaceLight,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
