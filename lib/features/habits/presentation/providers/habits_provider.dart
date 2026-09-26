import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/entities/habit.dart';
import '../../data/repositories/mock_habit_repository.dart';
import '../../domain/repositories/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) => MockHabitRepository());

class HabitsState {
  const HabitsState({
    this.habits = const [],
    this.isLoading = false,
    this.error,
  });

  final List<Habit> habits;
  final bool isLoading;
  final String? error;

  int get totalStreak => habits.fold(0, (sum, h) => sum + h.streak);

  double get avgConsistency =>
      habits.isEmpty ? 0 : habits.map((h) => h.consistencyRate).reduce((a, b) => a + b) / habits.length;

  int get completedToday => habits.where((h) => h.completedToday).length;
}

class HabitsNotifier extends StateNotifier<HabitsState> {
  HabitsNotifier(this._repo) : super(const HabitsState()) {
    loadHabits();
  }

  final HabitRepository _repo;

  Future<void> loadHabits() async {
    state = const HabitsState(isLoading: true);
    try {
      final habits = await _repo.getHabits();
      state = HabitsState(habits: habits);
    } catch (e) {
      state = HabitsState(error: e.toString());
    }
  }

  Future<Habit?> getHabit(String id) => _repo.getHabitById(id);

  Future<void> createHabit(Habit habit) async {
    final created = await _repo.createHabit(habit);
    state = HabitsState(habits: [...state.habits, created]);
  }

  Future<void> updateHabit(Habit habit) async {
    final updated = await _repo.updateHabit(habit);
    state = HabitsState(
      habits: state.habits.map((h) => h.id == updated.id ? updated : h).toList(),
    );
  }

  Future<void> deleteHabit(String id) async {
    await _repo.deleteHabit(id);
    state = HabitsState(habits: state.habits.where((h) => h.id != id).toList());
  }

  Future<void> toggleToday(String id) async {
    final updated = await _repo.toggleHabitToday(id);
    state = HabitsState(
      habits: state.habits.map((h) => h.id == updated.id ? updated : h).toList(),
    );
  }
}

final habitsStateProvider = StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  return HabitsNotifier(ref.watch(habitRepositoryProvider));
});

final habitByIdProvider = FutureProvider.family<Habit?, String>((ref, id) async {
  return ref.watch(habitRepositoryProvider).getHabitById(id);
});
