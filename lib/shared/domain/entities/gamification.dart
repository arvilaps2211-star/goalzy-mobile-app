import 'package:equatable/equatable.dart';

enum AchievementTier { bronze, silver, gold, platinum }

class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tier,
    this.isUnlocked = false,
    this.unlockedAt,
    this.xpReward = 100,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementTier tier;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int xpReward;

  @override
  List<Object?> get props => [id, isUnlocked];
}

class XpLog extends Equatable {
  const XpLog({
    required this.id,
    required this.amount,
    required this.reason,
    required this.timestamp,
  });

  final String id;
  final int amount;
  final String reason;
  final DateTime timestamp;

  @override
  List<Object?> get props => [id, amount];
}

class Streak extends Equatable {
  const Streak({
    required this.id,
    required this.type,
    required this.currentDays,
    required this.bestDays,
    this.lastActivityDate,
  });

  final String id;
  final String type;
  final int currentDays;
  final int bestDays;
  final DateTime? lastActivityDate;

  @override
  List<Object?> get props => [id, currentDays];
}
