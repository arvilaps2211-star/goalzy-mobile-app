import '../../../../shared/domain/entities/ai_message.dart';

abstract class AiRepository {
  Future<AiMessage> sendMessage(String message);
  Future<List<String>> getSuggestions();
  Future<List<AiContextCard>> getContextCards();
  List<AiMessage> getMessageHistory();
  void clearHistory();
}
