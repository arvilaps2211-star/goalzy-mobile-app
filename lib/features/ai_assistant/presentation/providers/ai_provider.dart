import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/domain/entities/ai_message.dart';
import '../../data/repositories/mock_ai_repository.dart';
import '../../domain/repositories/ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return MockAiRepository(ref.watch(aiServiceProvider));
});

class AiState {
  const AiState({
    this.messages = const [],
    this.suggestions = const [],
    this.contextCards = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  final List<AiMessage> messages;
  final List<String> suggestions;
  final List<AiContextCard> contextCards;
  final bool isLoading;
  final bool isSending;
  final String? error;
}

class AiNotifier extends StateNotifier<AiState> {
  AiNotifier(this._repo) : super(const AiState()) {
    _init();
  }

  final AiRepository _repo;

  Future<void> _init() async {
    state = const AiState(isLoading: true);
    try {
      final suggestions = await _repo.getSuggestions();
      final contextCards = await _repo.getContextCards();
      state = AiState(
        messages: _repo.getMessageHistory(),
        suggestions: suggestions,
        contextCards: contextCards,
      );
    } catch (e) {
      state = AiState(error: e.toString());
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isSending) return;
    state = AiState(
      messages: _repo.getMessageHistory(),
      suggestions: state.suggestions,
      contextCards: state.contextCards,
      isSending: true,
    );

    try {
      await _repo.sendMessage(text.trim());
      state = AiState(
        messages: _repo.getMessageHistory(),
        suggestions: state.suggestions,
        contextCards: state.contextCards,
      );
    } catch (e) {
      state = AiState(
        messages: _repo.getMessageHistory(),
        suggestions: state.suggestions,
        contextCards: state.contextCards,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshSuggestions() async {
    try {
      final suggestions = await _repo.getSuggestions();
      state = AiState(
        messages: state.messages,
        suggestions: suggestions,
        contextCards: state.contextCards,
      );
    } catch (_) {}
  }

  void clearChat() {
    _repo.clearHistory();
    state = AiState(
      suggestions: state.suggestions,
      contextCards: state.contextCards,
    );
  }
}

final aiStateProvider = StateNotifierProvider<AiNotifier, AiState>((ref) {
  return AiNotifier(ref.watch(aiRepositoryProvider));
});
