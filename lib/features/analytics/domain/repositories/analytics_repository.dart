import '../../../../shared/domain/entities/analytics.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsSnapshot> getSnapshot();
  Future<LifeScore> getTodayLifeScore();
  Future<List<LifeScore>> getLifeScoreHistory({int days = 7});
}
