import 'package:equatable/equatable.dart';

class LifeScore extends Equatable {
  const LifeScore({
    required this.overall,
    required this.energy,
    required this.focus,
    required this.motivation,
    required this.productivity,
    required this.date,
  });

  final double overall;
  final double energy;
  final double focus;
  final double motivation;
  final double productivity;
  final DateTime date;

  @override
  List<Object?> get props => [overall, date];
}

class AnalyticsSnapshot extends Equatable {
  const AnalyticsSnapshot({
    required this.lifeScoreHistory,
    required this.goalCompletionRate,
    required this.taskCompletionRate,
    required this.habitConsistencyRate,
    required this.weeklyReport,
    required this.monthlyReport,
  });

  final List<LifeScore> lifeScoreHistory;
  final double goalCompletionRate;
  final double taskCompletionRate;
  final double habitConsistencyRate;
  final Map<String, dynamic> weeklyReport;
  final Map<String, dynamic> monthlyReport;

  @override
  List<Object?> get props => [goalCompletionRate, taskCompletionRate];
}
