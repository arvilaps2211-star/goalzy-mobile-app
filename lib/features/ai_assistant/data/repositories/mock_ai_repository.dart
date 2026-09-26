import 'package:uuid/uuid.dart';
import '../../../../core/network/ai_service_stub.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/ai_message.dart';
import '../../domain/repositories/ai_repository.dart';

class MockAiRepository implements AiRepository {
  MockAiRepository(this._aiService);

  final AiServiceStub _aiService;
  final _uuid = const Uuid();
  final List<AiMessage> _history = [];

  @override
  List<AiMessage> getMessageHistory() => List.unmodifiable(_history);

  @override
  void clearHistory() => _history.clear();

  @override
  Future<AiMessage> sendMessage(String message) async {
    final userMessage = AiMessage(
      id: _uuid.v4(),
      content: message,
      role: AiMessageRole.user,
      timestamp: DateTime.now(),
    );
    _history.add(userMessage);

    final response = await _aiService.chat(
      message: message,
      context: MockData.brainContext.toAiPayload(),
    );

    final assistantMessage = AiMessage(
      id: _uuid.v4(),
      content: response,
      role: AiMessageRole.assistant,
      timestamp: DateTime.now(),
      contextCards: const ['goals', 'habits'],
    );
    _history.add(assistantMessage);
    return assistantMessage;
  }

  @override
  Future<List<String>> getSuggestions() async {
    return _aiService.getSuggestions(context: MockData.brainContext.toAiPayload());
  }

  @override
  Future<List<AiContextCard>> getContextCards() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final ctx = MockData.brainContext;
    return [
      AiContextCard(
        id: 'ctx-goals',
        title: '${ctx.goalContext['activeGoals']} Active Goals',
        subtitle: ctx.goalContext['topPriority'] as String? ?? 'No priority set',
        type: 'goal',
      ),
      AiContextCard(
        id: 'ctx-habits',
        title: 'Habit Consistency',
        subtitle: '${((ctx.habitContext['consistency'] as double? ?? 0) * 100).round()}% this week',
        type: 'habit',
      ),
      AiContextCard(
        id: 'ctx-productivity',
        title: 'Peak Hours',
        subtitle: ctx.productivityContext['peakHours'] as String? ?? 'Unknown',
        type: 'productivity',
      ),
    ];
  }
}
