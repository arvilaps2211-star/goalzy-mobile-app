import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/gamification.dart';
import '../entities/user_profile.dart';

/// Reusable gamification system — XP, Credits, Levels, Achievements, Streaks
class GamificationService {
  GamificationService();

  int calculateLevel(int xp) => (xp ~/ 1000) + 1;

  int xpForAction(String action) => switch (action) {
        'task_complete' => 25,
        'habit_log' => 15,
        'goal_milestone' => 100,
        'goal_complete' => 500,
        'streak_bonus' => 50,
        _ => 10,
      };

  UserProfile awardXp(UserProfile user, int amount, String reason) {
    final newXp = user.xp + amount;
    return user.copyWith(xp: newXp, level: calculateLevel(newXp));
  }

  UserProfile spendCredits(UserProfile user, int amount) {
    if (user.credits < amount) return user;
    return user.copyWith(credits: user.credits - amount);
  }

  bool checkAchievementUnlock(Achievement achievement, Map<String, dynamic> stats) {
    if (achievement.isUnlocked) return false;
    return switch (achievement.id) {
      'a1' => (stats['tasksCompleted'] as int? ?? 0) >= 1,
      'a2' => (stats['streakDays'] as int? ?? 0) >= 7,
      'a3' => (stats['goalsCompleted'] as int? ?? 0) >= 1,
      'a4' => (stats['aiMessages'] as int? ?? 0) >= 50,
      _ => false,
    };
  }
}

final gamificationServiceProvider = Provider<GamificationService>((ref) => GamificationService());
