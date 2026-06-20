import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/brain.dart';
import '../../data/mock_data.dart';

/// GOALZY Brain — context aggregation for future Gemini + Qdrant
class GoalzyBrainService {
  GoalzyBrainService();

  GoalzyBrainContext _context = MockData.brainContext;

  GoalzyBrainContext get context => _context;

  void updateGoalContext(Map<String, dynamic> data) {
    _context = _context.copyWith(goalContext: {..._context.goalContext, ...data});
  }

  void updateHabitContext(Map<String, dynamic> data) {
    _context = _context.copyWith(habitContext: {..._context.habitContext, ...data});
  }

  void updateProductivityContext(Map<String, dynamic> data) {
    _context = _context.copyWith(productivityContext: {..._context.productivityContext, ...data});
  }

  void addMemory(AiMemoryEntry entry) {
    _context = _context.copyWith(memoryEntries: [..._context.memoryEntries, entry]);
  }

  Map<String, dynamic> buildAiPayload() => _context.toAiPayload();
}

final goalzyBrainProvider = Provider<GoalzyBrainService>((ref) => GoalzyBrainService());
