import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/analytics.dart';
import '../../domain/repositories/analytics_repository.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<AnalyticsSnapshot> getSnapshot() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return MockData.analytics;
  }

  @override
  Future<LifeScore> getTodayLifeScore() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return MockData.todayLifeScore;
  }

  @override
  Future<List<LifeScore>> getLifeScoreHistory({int days = 7}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return MockData.analytics.lifeScoreHistory;
  }
}
