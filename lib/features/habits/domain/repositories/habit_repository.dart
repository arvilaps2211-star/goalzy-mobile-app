import '../../../../shared/domain/entities/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits();
  Future<Habit?> getHabitById(String id);
  Future<Habit> createHabit(Habit habit);
  Future<Habit> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<Habit> toggleHabitToday(String id);
}
