import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/entities/goal.dart';
import '../../data/repositories/mock_goal_repository.dart';
import '../../domain/repositories/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) => MockGoalRepository());

class GoalsState {
  const GoalsState({
    this.goals = const [],
    this.isLoading = false,
    this.error,
  });

  final List<Goal> goals;
  final bool isLoading;
  final String? error;

  List<Goal> get activeGoals => goals.where((g) => g.status == GoalStatus.active).toList();

  Map<GoalCategory, List<Goal>> get byCategory {
    final map = <GoalCategory, List<Goal>>{};
    for (final goal in goals) {
      map.putIfAbsent(goal.category, () => []).add(goal);
    }
    return map;
  }
}

class GoalsNotifier extends StateNotifier<GoalsState> {
  GoalsNotifier(this._repo) : super(const GoalsState()) {
    loadGoals();
  }

  final GoalRepository _repo;

  Future<void> loadGoals() async {
    state = const GoalsState(isLoading: true);
    try {
      final goals = await _repo.getGoals();
      state = GoalsState(goals: goals);
    } catch (e) {
      state = GoalsState(error: e.toString());
    }
  }

  Future<Goal?> getGoal(String id) => _repo.getGoalById(id);

  Future<void> createGoal(Goal goal) async {
    final created = await _repo.createGoal(goal);
    state = GoalsState(goals: [...state.goals, created]);
  }

  Future<void> updateGoal(Goal goal) async {
    final updated = await _repo.updateGoal(goal);
    state = GoalsState(
      goals: state.goals.map((g) => g.id == updated.id ? updated : g).toList(),
    );
  }

  Future<void> deleteGoal(String id) async {
    await _repo.deleteGoal(id);
    state = GoalsState(goals: state.goals.where((g) => g.id != id).toList());
  }

  Future<void> toggleMilestone(String goalId, String milestoneId) async {
    final updated = await _repo.toggleMilestone(goalId, milestoneId);
    state = GoalsState(
      goals: state.goals.map((g) => g.id == updated.id ? updated : g).toList(),
    );
  }
}

final goalsStateProvider = StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  return GoalsNotifier(ref.watch(goalRepositoryProvider));
});

final goalByIdProvider = FutureProvider.family<Goal?, String>((ref, id) async {
  return ref.watch(goalRepositoryProvider).getGoalById(id);
});
