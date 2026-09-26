import 'package:equatable/equatable.dart';

/// GOALZY Brain — context store for future Gemini + Qdrant integration.
class GoalzyBrainContext extends Equatable {
  const GoalzyBrainContext({
    this.goalContext = const {},
    this.habitContext = const {},
    this.productivityContext = const {},
    this.preferences = const {},
    this.memoryEntries = const [],
  });

  final Map<String, dynamic> goalContext;
  final Map<String, dynamic> habitContext;
  final Map<String, dynamic> productivityContext;
  final Map<String, dynamic> preferences;
  final List<AiMemoryEntry> memoryEntries;

  GoalzyBrainContext copyWith({
    Map<String, dynamic>? goalContext,
    Map<String, dynamic>? habitContext,
    Map<String, dynamic>? productivityContext,
    Map<String, dynamic>? preferences,
    List<AiMemoryEntry>? memoryEntries,
  }) {
    return GoalzyBrainContext(
      goalContext: goalContext ?? this.goalContext,
      habitContext: habitContext ?? this.habitContext,
      productivityContext: productivityContext ?? this.productivityContext,
      preferences: preferences ?? this.preferences,
      memoryEntries: memoryEntries ?? this.memoryEntries,
    );
  }

  Map<String, dynamic> toAiPayload() => {
        'goals': goalContext,
        'habits': habitContext,
        'productivity': productivityContext,
        'preferences': preferences,
      };

  @override
  List<Object?> get props => [goalContext, habitContext, productivityContext];
}

class AiMemoryEntry extends Equatable {
  const AiMemoryEntry({
    required this.id,
    required this.content,
    required this.category,
    required this.timestamp,
    this.embeddingId,
  });

  final String id;
  final String content;
  final String category;
  final DateTime timestamp;
  final String? embeddingId;

  @override
  List<Object?> get props => [id, content];
}

/// V2 placeholder — Auto Pilot plans
class AutopilotPlan extends Equatable {
  const AutopilotPlan({
    required this.id,
    required this.title,
    required this.scheduledTasks,
    required this.date,
    this.isActive = false,
  });

  final String id;
  final String title;
  final List<String> scheduledTasks;
  final DateTime date;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}
