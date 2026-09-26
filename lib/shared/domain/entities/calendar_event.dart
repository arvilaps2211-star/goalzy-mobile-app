import 'package:equatable/equatable.dart';

enum CalendarEventType { task, habit, goal, focus, meeting, reminder }

class CalendarEvent extends Equatable {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.type = CalendarEventType.task,
    this.colorHex = '6D5DF6',
    this.isAllDay = false,
    this.linkedId,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final CalendarEventType type;
  final String colorHex;
  final bool isAllDay;
  final String? linkedId;

  @override
  List<Object?> get props => [id, title, startTime];
}
