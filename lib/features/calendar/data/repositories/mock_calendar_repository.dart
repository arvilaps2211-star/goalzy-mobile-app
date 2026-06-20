import '../../../../core/utils/date_utils.dart' as gd;
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';

class MockCalendarRepository implements CalendarRepository {
  List<CalendarEvent> get _events => MockData.calendarEvents;

  @override
  Future<List<CalendarEvent>> getEventsForDay(DateTime date) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _events
        .where((e) => gd.DateUtils.isSameDay(e.startTime, date))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<List<CalendarEvent>> getEventsForWeek(DateTime weekStart) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final start = gd.DateUtils.startOfWeek(weekStart);
    final end = start.add(const Duration(days: 7));
    return _events
        .where((e) => !e.startTime.isBefore(start) && e.startTime.isBefore(end))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<List<CalendarEvent>> getEventsForMonth(DateTime month) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _events
        .where((e) => e.startTime.year == month.year && e.startTime.month == month.month)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<List<CalendarEvent>> getEventsInRange(DateTime start, DateTime end) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _events
        .where((e) => !e.startTime.isBefore(start) && e.startTime.isBefore(end))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
}
