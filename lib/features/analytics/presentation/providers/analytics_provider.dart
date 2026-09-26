import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/entities/analytics.dart';
import '../../data/repositories/mock_analytics_repository.dart';
import '../../domain/repositories/analytics_repository.dart';

enum ReportPeriod { weekly, monthly }

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return MockAnalyticsRepository();
});

class AnalyticsState {
  const AnalyticsState({
    this.snapshot,
    this.reportPeriod = ReportPeriod.weekly,
    this.isLoading = false,
    this.error,
  });

  final AnalyticsSnapshot? snapshot;
  final ReportPeriod reportPeriod;
  final bool isLoading;
  final String? error;
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier(this._repo) : super(const AnalyticsState()) {
    load();
  }

  final AnalyticsRepository _repo;

  Future<void> load() async {
    state = AnalyticsState(reportPeriod: state.reportPeriod, isLoading: true);
    try {
      final snapshot = await _repo.getSnapshot();
      state = AnalyticsState(snapshot: snapshot, reportPeriod: state.reportPeriod);
    } catch (e) {
      state = AnalyticsState(reportPeriod: state.reportPeriod, error: e.toString());
    }
  }

  void setReportPeriod(ReportPeriod period) {
    state = AnalyticsState(snapshot: state.snapshot, reportPeriod: period);
  }
}

final analyticsStateProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref.watch(analyticsRepositoryProvider));
});

final todayLifeScoreProvider = FutureProvider<LifeScore>((ref) {
  return ref.watch(analyticsRepositoryProvider).getTodayLifeScore();
});
