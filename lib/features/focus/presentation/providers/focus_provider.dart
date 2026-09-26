import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/domain/entities/focus_session.dart';
import '../../data/repositories/mock_focus_repository.dart';
import '../../domain/repositories/focus_repository.dart';

final focusRepositoryProvider = Provider<FocusRepository>((ref) => MockFocusRepository());

enum FocusTimerStatus { idle, running, paused, completed }

class FocusState {
  const FocusState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
    this.status = FocusTimerStatus.idle,
    this.totalSeconds = 25 * 60,
    this.remainingSeconds = 25 * 60,
    this.label,
  });

  final List<FocusSession> sessions;
  final bool isLoading;
  final String? error;
  final FocusTimerStatus status;
  final int totalSeconds;
  final int remainingSeconds;
  final String? label;

  double get progress => totalSeconds == 0 ? 0 : 1 - (remainingSeconds / totalSeconds);

  List<FocusSession> get _todaysCompleted {
    final now = DateTime.now();
    return sessions
        .where((s) => s.completed && s.startTime.year == now.year && s.startTime.month == now.month && s.startTime.day == now.day)
        .toList();
  }

  int get todayMinutes => _todaysCompleted.fold(0, (sum, s) => sum + s.actualMinutes);
  int get todaySessionCount => _todaysCompleted.length;

  FocusState copyWith({
    List<FocusSession>? sessions,
    bool? isLoading,
    String? error,
    FocusTimerStatus? status,
    int? totalSeconds,
    int? remainingSeconds,
    String? label,
  }) {
    return FocusState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? false,
      error: error,
      status: status ?? this.status,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      label: label ?? this.label,
    );
  }
}

class FocusNotifier extends StateNotifier<FocusState> {
  FocusNotifier(this._repo) : super(const FocusState()) {
    loadSessions();
  }

  final FocusRepository _repo;
  Timer? _timer;
  DateTime? _sessionStart;

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true);
    try {
      final sessions = await _repo.getSessions();
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Only allowed while idle — changing the preset mid-session would be
  /// confusing, so the UI hides duration chips once a session starts.
  void setDuration(int minutes) {
    if (state.status == FocusTimerStatus.running || state.status == FocusTimerStatus.paused) return;
    final seconds = minutes * 60;
    state = state.copyWith(totalSeconds: seconds, remainingSeconds: seconds, status: FocusTimerStatus.idle);
  }

  void setLabel(String? label) => state = state.copyWith(label: label);

  void start() {
    _sessionStart ??= DateTime.now();
    state = state.copyWith(status: FocusTimerStatus.running);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: FocusTimerStatus.paused);
  }

  void reset() {
    _timer?.cancel();
    _sessionStart = null;
    state = state.copyWith(status: FocusTimerStatus.idle, remainingSeconds: state.totalSeconds);
  }

  void _tick() {
    if (state.remainingSeconds <= 1) {
      _timer?.cancel();
      _completeSession();
    } else {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    }
  }

  Future<void> _completeSession() async {
    final start = _sessionStart ?? DateTime.now();
    final plannedMinutes = state.totalSeconds ~/ 60;
    final session = FocusSession(
      id: const Uuid().v4(),
      startTime: start,
      endTime: DateTime.now(),
      plannedMinutes: plannedMinutes,
      actualMinutes: plannedMinutes,
      label: state.label,
      completed: true,
    );
    _sessionStart = null;
    state = state.copyWith(status: FocusTimerStatus.completed, remainingSeconds: 0);
    final saved = await _repo.logSession(session);
    state = state.copyWith(sessions: [...state.sessions, saved]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusStateProvider = StateNotifierProvider<FocusNotifier, FocusState>((ref) {
  return FocusNotifier(ref.watch(focusRepositoryProvider));
});
