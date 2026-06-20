import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/components/adaptive_layout.dart';
import '../../../../shared/widgets/components/ai_orb.dart';
import '../../../ai_assistant/presentation/screens/ai_chat_screen.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../calendar/presentation/screens/calendar_screen.dart';
import '../../../goals/presentation/screens/goals_screen.dart';
import '../../../habits/presentation/screens/habits_screen.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import 'dashboard_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  static const _navItems = [
    AdaptiveNavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      route: AppRoutes.home,
    ),
    AdaptiveNavItem(
      icon: Icons.flag_outlined,
      selectedIcon: Icons.flag,
      label: 'Goals',
      route: AppRoutes.goals,
    ),
    AdaptiveNavItem(
      icon: Icons.check_circle_outline,
      selectedIcon: Icons.check_circle,
      label: 'Tasks',
      route: AppRoutes.tasks,
    ),
    AdaptiveNavItem(
      icon: Icons.repeat,
      selectedIcon: Icons.repeat_on,
      label: 'Habits',
      route: AppRoutes.habits,
    ),
    AdaptiveNavItem(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      label: 'Calendar',
      route: AppRoutes.calendar,
    ),
    AdaptiveNavItem(
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Analytics',
      route: AppRoutes.analytics,
    ),
    AdaptiveNavItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: 'AI',
      route: AppRoutes.ai,
    ),
  ];

  late final List<Widget> _screens = const [
    DashboardScreen(),
    GoalsScreen(),
    TasksScreen(),
    HabitsScreen(),
    CalendarScreen(),
    AnalyticsScreen(),
    AiChatScreen(),
  ];

  void _onNavChanged(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return AdaptiveLayout(
      selectedIndex: _selectedIndex,
      navigationItems: _navItems,
      onNavigationChanged: _onNavChanged,
      floatingAction: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: AIOrb(
          onTap: () => setState(() => _selectedIndex = 6),
        ),
      ),
      appBar: AppBar(
        title: Text(_navItems[_selectedIndex].label),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push('${AppRoutes.home}/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('${AppRoutes.home}/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('${AppRoutes.home}/settings'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}
