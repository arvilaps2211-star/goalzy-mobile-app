import 'package:equatable/equatable.dart';

enum HabitFrequency { daily, weekly, custom }

class HabitLog extends Equatable {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = true,
    this.note,
  });

  final String id;
  final String habitId;
  final DateTime date;
  final bool completed;
  final String? note;

  @override
  List<Object?> get props => [id, habitId, date, completed];
}

class Habit extends Equatable {
  const Habit({
    required this.id,
    required this.title,
    this.description = '',
    this.frequency = HabitFrequency.daily,
    this.icon = '✨',
    this.colorHex = '00D4FF',
    this.streak = 0,
    this.bestStreak = 0,
    this.consistencyRate = 0,
    this.targetDays = 7,
    this.completedToday = false,
    this.logs = const [],
  });

  final String id;
  final String title;
  final String description;
  final HabitFrequency frequency;
  final String icon;
  final String colorHex;
  final int streak;
  final int bestStreak;
  final double consistencyRate;
  final int targetDays;
  final bool completedToday;
  final List<HabitLog> logs;

  Habit copyWith({
    int? streak,
    bool? completedToday,
    double? consistencyRate,
    List<HabitLog>? logs,
  }) {
    return Habit(
      id: id,
      title: title,
      description: description,
      frequency: frequency,
      icon: icon,
      colorHex: colorHex,
      streak: streak ?? this.streak,
      bestStreak: bestStreak,
      consistencyRate: consistencyRate ?? this.consistencyRate,
      targetDays: targetDays,
      completedToday: completedToday ?? this.completedToday,
      logs: logs ?? this.logs,
    );
  }

  @override
  List<Object?> get props => [id, title, streak, completedToday];
}
