import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/module_theme.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../shared/widgets/components/adaptive_layout.dart';
import '../../../../shared/widgets/components/module_background.dart';
import '../../../ai_assistant/presentation/screens/ai_chat_screen.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../calendar/presentation/screens/calendar_screen.dart';
import '../../../goals/presentation/screens/goals_screen.dart';
import '../../../habits/presentation/screens/habits_screen.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import 'dashboard_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  static const _centerIndex = 2;

  // Home and Profile use CupertinoIcons (the two identifiers I'm fully
  // confident about) for a more authentically-iOS look in the nav bar —
  // cupertino_icons has been a declared pubspec dependency this whole
  // project, never actually used until now. Lists/AI/Analytics are left
  // on their existing, already-correct Material icons rather than risk
  // guessing at a less-certain Cupertino identifier.
  static const _navItems = [
    AdaptiveNavItem(
      icon: CupertinoIcons.house,
      selectedIcon: CupertinoIcons.house_fill,
      label: 'Home',
      route: AppRoutes.home,
    ),
    AdaptiveNavItem(
      icon: Icons.view_list_outlined,
      selectedIcon: Icons.view_list_rounded,
      label: 'Lists',
      route: AppRoutes.goals,
    ),
    AdaptiveNavItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: 'AI',
      route: AppRoutes.ai,
    ),
    AdaptiveNavItem(
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
      label: 'Analytics',
      route: AppRoutes.analytics,
    ),
    AdaptiveNavItem(
      icon: CupertinoIcons.person,
      selectedIcon: CupertinoIcons.person_fill,
      label: 'Profile',
      route: AppRoutes.profile,
    ),
  ];

  // Each tab is wrapped in its module identity (see core/theme/module_theme.dart).
  // "Lists" mixes four modules internally, so it's left unwrapped here — its
  // sub-tabs are scoped individually inside _ListsHubScreen below.
  late final List<Widget> _screens = const [
    _ModuleTab(module: GoalzyModule.dashboard, child: DashboardScreen()),
    _ListsHubScreen(),
    _ModuleTab(module: GoalzyModule.aiAssistant, child: AiChatScreen(embedded: true)),
    _ModuleTab(module: GoalzyModule.analytics, child: AnalyticsScreen()),
    _ModuleTab(module: GoalzyModule.profile, child: ProfileScreen(embedded: true)),
  ];

  @override
  Widget build(BuildContext context) {
    ref.watch(unreadNotificationsCountProvider);

    return AdaptiveLayout(
      selectedIndex: _selectedIndex,
      navigationItems: _navItems,
      centerActionIndex: _centerIndex,
      onCenterAction: () => setState(() => _selectedIndex = _centerIndex),
      onNavigationChanged: (index) {
        if (index != _centerIndex) setState(() => _selectedIndex = index);
      },
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}

/// Lists hub — Goals, Tasks, Habits, Calendar without changing feature modules.
class _ListsHubScreen extends StatefulWidget {
  const _ListsHubScreen();

  @override
  State<_ListsHubScreen> createState() => _ListsHubScreenState();
}

class _ListsHubScreenState extends State<_ListsHubScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text('Lists', style: Theme.of(context).textTheme.headlineMedium),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: g.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          labelColor: g.primary,
          unselectedLabelColor: g.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Goals'),
            Tab(text: 'Tasks'),
            Tab(text: 'Habits'),
            Tab(text: 'Calendar'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _ModuleTab(module: GoalzyModule.goals, child: GoalsScreen()),
              _ModuleTab(module: GoalzyModule.tasks, child: TasksScreen()),
              _ModuleTab(module: GoalzyModule.habits, child: HabitsScreen()),
              _ModuleTab(module: GoalzyModule.calendar, child: CalendarScreen()),
            ],
          ),
        ),
      ],
    );
  }
}

/// Establishes a module's identity for one tab/sub-tab: scopes
/// `context.moduleTheme` for everything below it and paints that module's
/// subtle decorative background behind its (otherwise untouched) content.
///
/// Purely additive — `child` renders exactly as it did before; this only
/// adds a backdrop layer behind it.
class _ModuleTab extends StatelessWidget {
  const _ModuleTab({required this.module, required this.child});

  final GoalzyModule module;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ModuleScope(
      module: module,
      child: Stack(
        children: [
          const Positioned.fill(child: ModuleBackground()),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
