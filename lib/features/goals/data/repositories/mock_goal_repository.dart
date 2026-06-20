import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';

class MockGoalRepository implements GoalRepository {
  final List<Goal> _goals = List<Goal>.from(MockData.goals);

  @override
  Future<List<Goal>> getGoals() async => List.unmodifiable(_goals);

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    _goals.add(goal);
    return goal;
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index == -1) throw StateError('Goal not found');
    _goals[index] = goal;
    return goal;
  }

  @override
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
  }

  @override
  Future<Goal> toggleMilestone(String goalId, String milestoneId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) throw StateError('Goal not found');

    final goal = _goals[index];
    final milestones = goal.milestones.map((m) {
      if (m.id != milestoneId) return m;
      final completed = !m.isCompleted;
      return m.copyWith(
        isCompleted: completed,
        completedAt: completed ? DateTime.now() : null,
      );
    }).toList();

    final completedCount = milestones.where((m) => m.isCompleted).length;
    final progress = milestones.isEmpty ? goal.progress : completedCount / milestones.length;

    final updated = goal.copyWith(milestones: milestones, progress: progress);
    _goals[index] = updated;
    return updated;
  }
}
