import '../../../../shared/domain/entities/calendar_event.dart';

abstract class CalendarRepository {
  Future<List<CalendarEvent>> getEventsForDay(DateTime date);
  Future<List<CalendarEvent>> getEventsForWeek(DateTime weekStart);
  Future<List<CalendarEvent>> getEventsForMonth(DateTime month);
  Future<List<CalendarEvent>> getEventsInRange(DateTime start, DateTime end);
}
