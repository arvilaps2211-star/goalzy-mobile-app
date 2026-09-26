import '../../../../shared/domain/entities/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> getGoals();
  Future<Goal?> getGoalById(String id);
  Future<Goal> createGoal(Goal goal);
  Future<Goal> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
  Future<Goal> toggleMilestone(String goalId, String milestoneId);
}
