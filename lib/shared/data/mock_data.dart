import '../domain/entities/analytics.dart';
import '../domain/entities/brain.dart';
import '../domain/entities/calendar_event.dart';
import '../domain/entities/gamification.dart';
import '../domain/entities/goal.dart';
import '../domain/entities/habit.dart';
import '../domain/entities/notification.dart';
import '../domain/entities/task_item.dart';
import '../domain/entities/user_profile.dart';

/// Central mock data for development. Replace with Supabase repositories later.
abstract final class MockData {
  static final user = UserProfile(
    id: 'user-1',
    email: 'alex@goalzy.app',
    displayName: 'Alex Morgan',
    avatarUrl: null,
    level: 12,
    xp: 8450,
    credits: 250,
    streakDays: 14,
    isPremium: false,
    createdAt: DateTime(2025, 3, 10),
  );

  static final goals = [
    Goal(
      id: 'goal-1',
      title: 'Launch SaaS Product',
      description: 'Build and launch GOALZY to 10K users',
      category: GoalCategory.career,
      targetDate: DateTime(2026, 12, 31),
      progress: 0.62,
      milestones: [
        GoalMilestone(id: 'm1', title: 'MVP Complete', targetDate: DateTime(2026, 3, 1), isCompleted: true, completedAt: DateTime(2026, 2, 28)),
        GoalMilestone(id: 'm2', title: 'Beta Launch', targetDate: DateTime(2026, 6, 1), isCompleted: true),
        GoalMilestone(id: 'm3', title: '10K Users', targetDate: DateTime(2026, 12, 31)),
      ],
      createdAt: DateTime(2025, 9, 1),
    ),
    Goal(
      id: 'goal-2',
      title: 'Run a Marathon',
      description: 'Complete first marathon under 4 hours',
      category: GoalCategory.fitness,
      targetDate: DateTime(2026, 10, 15),
      progress: 0.35,
      colorHex: '00E396',
      milestones: [
        GoalMilestone(id: 'm4', title: 'Run 10K', targetDate: DateTime(2026, 4, 1), isCompleted: true),
        GoalMilestone(id: 'm5', title: 'Half Marathon', targetDate: DateTime(2026, 7, 1)),
      ],
    ),
    Goal(
      id: 'goal-3',
      title: 'Learn Flutter Mastery',
      description: 'Advanced Flutter & architecture patterns',
      category: GoalCategory.learning,
      targetDate: DateTime(2026, 8, 30),
      progress: 0.78,
      colorHex: '00D4FF',
    ),
  ];

  static final tasks = [
    TaskItem(
      id: 'task-1',
      title: 'Review sprint backlog',
      priority: TaskPriority.high,
      dueDate: DateTime.now(),
      aiSuggestion: 'Block 30 min before standup for best focus',
    ),
    TaskItem(
      id: 'task-2',
      title: 'Design dashboard widgets',
      priority: TaskPriority.medium,
      dueDate: DateTime.now(),
      status: TaskStatus.inProgress,
      goalId: 'goal-1',
    ),
    TaskItem(
      id: 'task-3',
      title: 'Morning run — 5K',
      priority: TaskPriority.medium,
      dueDate: DateTime.now(),
      goalId: 'goal-2',
    ),
    TaskItem(
      id: 'task-4',
      title: 'Read Flutter architecture docs',
      priority: TaskPriority.low,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      goalId: 'goal-3',
      isRecurring: true,
      recurrenceRule: 'daily',
    ),
    TaskItem(
      id: 'task-5',
      title: 'Team sync meeting',
      priority: TaskPriority.urgent,
      dueDate: DateTime.now().add(const Duration(hours: 2)),
    ),
    TaskItem(
      id: 'task-6',
      title: 'Update investor deck',
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      goalId: 'goal-1',
      status: TaskStatus.completed,
      completedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  static final habits = [
    Habit(
      id: 'habit-1',
      title: 'Morning Meditation',
      icon: '🧘',
      streak: 14,
      bestStreak: 21,
      consistencyRate: 0.92,
      completedToday: true,
      colorHex: '6D5DF6',
    ),
    Habit(
      id: 'habit-2',
      title: 'Drink 8 Glasses Water',
      icon: '💧',
      streak: 7,
      bestStreak: 14,
      consistencyRate: 0.85,
      completedToday: false,
      colorHex: '00D4FF',
    ),
    Habit(
      id: 'habit-3',
      title: 'Code 1 Hour',
      icon: '💻',
      streak: 21,
      bestStreak: 30,
      consistencyRate: 0.95,
      completedToday: true,
      colorHex: '00E396',
    ),
    Habit(
      id: 'habit-4',
      title: 'Journal',
      icon: '📝',
      streak: 5,
      bestStreak: 12,
      consistencyRate: 0.71,
      completedToday: false,
      colorHex: 'FFB547',
    ),
  ];

  static List<CalendarEvent> get calendarEvents {
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: 'evt-1',
        title: 'Review sprint backlog',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 10, 0),
        type: CalendarEventType.task,
        linkedId: 'task-1',
      ),
      CalendarEvent(
        id: 'evt-2',
        title: 'Team sync',
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 0),
        type: CalendarEventType.meeting,
      ),
      CalendarEvent(
        id: 'evt-3',
        title: 'Morning run',
        startTime: DateTime(now.year, now.month, now.day, 7, 0),
        endTime: DateTime(now.year, now.month, now.day, 7, 45),
        type: CalendarEventType.habit,
        colorHex: '00E396',
      ),
      CalendarEvent(
        id: 'evt-4',
        title: 'Focus block — Design',
        startTime: DateTime(now.year, now.month, now.day, 10, 30),
        endTime: DateTime(now.year, now.month, now.day, 12, 0),
        type: CalendarEventType.focus,
        colorHex: '6D5DF6',
      ),
    ];
  }

  static LifeScore get todayLifeScore => LifeScore(
        overall: 82,
        energy: 75,
        focus: 88,
        motivation: 79,
        productivity: 86,
        date: DateTime.now(),
      );

  static AnalyticsSnapshot get analytics => AnalyticsSnapshot(
        lifeScoreHistory: List.generate(
          7,
          (i) => LifeScore(
            overall: 70 + i * 2.0,
            energy: 65 + i * 1.5,
            focus: 72 + i * 2,
            motivation: 68 + i * 1.8,
            productivity: 75 + i * 1.5,
            date: DateTime.now().subtract(Duration(days: 6 - i)),
          ),
        ),
        goalCompletionRate: 0.68,
        taskCompletionRate: 0.74,
        habitConsistencyRate: 0.86,
        weeklyReport: {
          'tasksCompleted': 24,
          'habitsLogged': 18,
          'goalsAdvanced': 3,
          'xpEarned': 450,
        },
        monthlyReport: {
          'tasksCompleted': 98,
          'habitsLogged': 72,
          'goalsCompleted': 1,
          'xpEarned': 1850,
        },
      );

  static final achievements = [
    Achievement(id: 'a1', title: 'First Steps', description: 'Complete your first task', icon: '🎯', tier: AchievementTier.bronze, isUnlocked: true, unlockedAt: DateTime(2025, 3, 12)),
    Achievement(id: 'a2', title: 'Streak Master', description: '7-day streak', icon: '🔥', tier: AchievementTier.silver, isUnlocked: true, unlockedAt: DateTime(2025, 4, 20)),
    const Achievement(id: 'a3', title: 'Goal Crusher', description: 'Complete a goal', icon: '🏆', tier: AchievementTier.gold, isUnlocked: false),
    const Achievement(id: 'a4', title: 'AI Pioneer', description: 'Use AI assistant 50 times', icon: '🤖', tier: AchievementTier.platinum, isUnlocked: false),
  ];

  static final notifications = [
    AppNotification(
      id: 'n1',
      title: 'Task Due Soon',
      body: 'Review sprint backlog is due in 2 hours',
      type: NotificationType.task,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      actionRoute: '/home/tasks/task-1',
    ),
    AppNotification(
      id: 'n2',
      title: 'Habit Reminder',
      body: 'Time for your morning meditation',
      type: NotificationType.habit,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      actionRoute: '/home/habits/habit-1',
    ),
    AppNotification(
      id: 'n3',
      title: 'AI Insight',
      body: 'Your productivity peaks at 10 AM — schedule deep work then',
      type: NotificationType.ai,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
      actionRoute: '/home/ai',
    ),
    AppNotification(
      id: 'n4',
      title: 'Achievement Unlocked!',
      body: 'You earned Streak Master badge',
      type: NotificationType.achievement,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      actionRoute: '/home/profile',
    ),
  ];

  static final brainContext = GoalzyBrainContext(
    goalContext: {'activeGoals': 3, 'topPriority': 'Launch SaaS Product'},
    habitContext: {'streakLeader': 'Code 1 Hour', 'consistency': 0.86},
    productivityContext: {'peakHours': '9-11 AM', 'focusScore': 88},
    preferences: {'coachingStyle': 'motivational', 'planningHorizon': 'weekly'},
  );

  static final recentActivity = [
    {'action': 'Completed task', 'item': 'Update investor deck', 'time': DateTime.now().subtract(const Duration(hours: 3))},
    {'action': 'Logged habit', 'item': 'Morning Meditation', 'time': DateTime.now().subtract(const Duration(hours: 5))},
    {'action': 'Goal milestone', 'item': 'Beta Launch achieved', 'time': DateTime.now().subtract(const Duration(days: 1))},
    {'action': 'Earned XP', 'item': '+50 XP for task completion', 'time': DateTime.now().subtract(const Duration(days: 1))},
  ];
}
