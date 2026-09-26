import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_utils.dart' as gd;
import '../../../../shared/domain/entities/calendar_event.dart';
import '../../data/repositories/mock_calendar_repository.dart';
import '../../domain/repositories/calendar_repository.dart';

enum CalendarViewMode { daily, weekly, monthly, agenda }

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return MockCalendarRepository();
});

class CalendarState {
  CalendarState({
    DateTime? selectedDate,
    this.viewMode = CalendarViewMode.daily,
    this.events = const [],
    this.isLoading = false,
    this.error,
  }) : selectedDate = selectedDate ?? DateTime.now();

  final DateTime selectedDate;
  final CalendarViewMode viewMode;
  final List<CalendarEvent> events;
  final bool isLoading;
  final String? error;
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier(this._repo) : super(CalendarState()) {
    loadEvents();
  }

  final CalendarRepository _repo;

  Future<void> loadEvents() async {
    final date = state.selectedDate;
    state = CalendarState(
      selectedDate: date,
      viewMode: state.viewMode,
      isLoading: true,
    );

    try {
      final events = switch (state.viewMode) {
        CalendarViewMode.daily => await _repo.getEventsForDay(date),
        CalendarViewMode.weekly => await _repo.getEventsForWeek(date),
        CalendarViewMode.monthly => await _repo.getEventsForMonth(date),
        CalendarViewMode.agenda => await _repo.getEventsInRange(
            gd.DateUtils.startOfDay(date),
            gd.DateUtils.startOfDay(date).add(const Duration(days: 14)),
          ),
      };
      state = CalendarState(
        selectedDate: date,
        viewMode: state.viewMode,
        events: events,
      );
    } catch (e) {
      state = CalendarState(
        selectedDate: date,
        viewMode: state.viewMode,
        error: e.toString(),
      );
    }
  }

  void setViewMode(CalendarViewMode mode) {
    if (state.viewMode == mode) return;
    state = CalendarState(selectedDate: state.selectedDate, viewMode: mode);
    loadEvents();
  }

  void selectDate(DateTime date) {
    state = CalendarState(selectedDate: date, viewMode: state.viewMode);
    loadEvents();
  }

  void goToToday() => selectDate(DateTime.now());

  void goToPrevious() {
    final date = state.selectedDate;
    final next = switch (state.viewMode) {
      CalendarViewMode.daily || CalendarViewMode.agenda => date.subtract(const Duration(days: 1)),
      CalendarViewMode.weekly => date.subtract(const Duration(days: 7)),
      CalendarViewMode.monthly => DateTime(date.year, date.month - 1, date.day),
    };
    selectDate(next);
  }

  void goToNext() {
    final date = state.selectedDate;
    final next = switch (state.viewMode) {
      CalendarViewMode.daily || CalendarViewMode.agenda => date.add(const Duration(days: 1)),
      CalendarViewMode.weekly => date.add(const Duration(days: 7)),
      CalendarViewMode.monthly => DateTime(date.year, date.month + 1, date.day),
    };
    selectDate(next);
  }
}

final calendarStateProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier(ref.watch(calendarRepositoryProvider));
});
