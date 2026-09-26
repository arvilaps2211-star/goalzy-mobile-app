import 'package:equatable/equatable.dart';

enum FocusSessionType { deepWork, shortBreak, longBreak }

class FocusSession extends Equatable {
  const FocusSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.plannedMinutes,
    this.actualMinutes = 0,
    this.type = FocusSessionType.deepWork,
    this.label,
    this.completed = false,
  });

  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedMinutes;
  final int actualMinutes;
  final FocusSessionType type;
  final String? label;
  final bool completed;

  FocusSession copyWith({
    DateTime? endTime,
    int? actualMinutes,
    bool? completed,
  }) {
    return FocusSession(
      id: id,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      plannedMinutes: plannedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      type: type,
      label: label,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [id, startTime, plannedMinutes, completed];
}
