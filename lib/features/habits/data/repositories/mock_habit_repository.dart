import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';

class MockHabitRepository implements HabitRepository {
  final List<Habit> _habits = List<Habit>.from(MockData.habits);

  @override
  Future<List<Habit>> getHabits() async => List.unmodifiable(_habits);

  @override
  Future<Habit?> getHabitById(String id) async {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Habit> createHabit(Habit habit) async {
    _habits.add(habit);
    return habit;
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) throw StateError('Habit not found');
    _habits[index] = habit;
    return habit;
  }

  @override
  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
  }

  @override
  Future<Habit> toggleHabitToday(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) throw StateError('Habit not found');

    final habit = _habits[index];
    final completed = !habit.completedToday;
    final newStreak = completed ? habit.streak + 1 : (habit.streak > 0 ? habit.streak - 1 : 0);
    final bestStreak = newStreak > habit.bestStreak ? newStreak : habit.bestStreak;

    final updated = habit.copyWith(
      completedToday: completed,
      streak: newStreak,
      consistencyRate: (habit.consistencyRate * 0.9 + (completed ? 0.1 : 0)).clamp(0.0, 1.0),
    );

    final withBest = Habit(
      id: updated.id,
      title: updated.title,
      description: updated.description,
      frequency: updated.frequency,
      icon: updated.icon,
      colorHex: updated.colorHex,
      streak: newStreak,
      bestStreak: bestStreak,
      consistencyRate: updated.consistencyRate,
      targetDays: updated.targetDays,
      completedToday: completed,
      logs: updated.logs,
    );

    _habits[index] = withBest;
    return withBest;
  }
}
