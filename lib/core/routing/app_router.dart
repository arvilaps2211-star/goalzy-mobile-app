import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/main_shell.dart';
import '../../features/goals/presentation/screens/goal_detail_screen.dart';
import '../../features/goals/presentation/screens/goal_create_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/habits/presentation/screens/habit_detail_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_chat_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const goals = '/goals';
  static const goalCreate = '/goals/create';
  static const goalDetail = '/goals/:id';
  static const tasks = '/tasks';
  static const taskDetail = '/tasks/:id';
  static const habits = '/habits';
  static const habitDetail = '/habits/:id';
  static const calendar = '/calendar';
  static const analytics = '/analytics';
  static const ai = '/ai';
  static const profile = '/profile';
  static const settings = '/settings';
  static const notifications = '/notifications';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isGuest = authState.isGuest;
      final onSplash = state.matchedLocation == AppRoutes.splash;
      final onLogin = state.matchedLocation == AppRoutes.login;

      if (onSplash) return null;
      if (!isLoggedIn && !isGuest && !onLogin) return AppRoutes.login;
      if ((isLoggedIn || isGuest) && onLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const MainShell(),
        routes: [
          GoRoute(path: 'goals/create', builder: (_, __) => const GoalCreateScreen()),
          GoRoute(
            path: 'goals/:id',
            builder: (context, state) => GoalDetailScreen(goalId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'tasks/:id',
            builder: (context, state) => TaskDetailScreen(taskId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'habits/:id',
            builder: (context, state) => HabitDetailScreen(habitId: state.pathParameters['id']!),
          ),
          GoRoute(path: 'ai', builder: (_, __) => const AiChatScreen()),
          GoRoute(path: 'profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: 'settings', builder: (_, __) => const SettingsScreen()),
          GoRoute(path: 'notifications', builder: (_, __) => const NotificationsScreen()),
        ],
      ),
    ],
  );
});
