import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_utils.dart';

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.body,
    this.navigationItems,
    this.selectedIndex = 0,
    this.onNavigationChanged,
    this.floatingAction,
    this.appBar,
  });

  final Widget body;
  final List<AdaptiveNavItem>? navigationItems;
  final int selectedIndex;
  final ValueChanged<int>? onNavigationChanged;
  final Widget? floatingAction;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final items = navigationItems ?? [];

    return Scaffold(
      extendBody: true,
      appBar: appBar,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              if (responsive.isDesktop && items.isNotEmpty)
                _SidebarNav(
                  items: items,
                  selectedIndex: selectedIndex,
                  onChanged: onNavigationChanged,
                )
              else if (responsive.isTablet && items.isNotEmpty)
                _RailNav(
                  items: items,
                  selectedIndex: selectedIndex,
                  onChanged: onNavigationChanged,
                ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: responsive.contentMaxWidth),
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: floatingAction,
      bottomNavigationBar: responsive.isPhone && items.isNotEmpty
          ? GlassBottomNavigation(
              items: items,
              selectedIndex: selectedIndex,
              onChanged: onNavigationChanged ?? (_) {},
            )
          : null,
    );
  }
}

class AdaptiveNavItem {
  const AdaptiveNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
}

class GlassBottomNavigation extends StatelessWidget {
  const GlassBottomNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<AdaptiveNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: AppConstants.navBarHeight,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final item = items[i];
          final selected = i == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? item.selectedIcon : item.icon,
                    color: selected ? AppColors.primary : AppColors.textMuted,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RailNav extends StatelessWidget {
  const _RailNav({required this.items, required this.selectedIndex, required this.onChanged});

  final List<AdaptiveNavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: AppColors.surface.withValues(alpha: 0.5),
      selectedIndex: selectedIndex,
      onDestinationSelected: onChanged,
      labelType: NavigationRailLabelType.all,
      indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      selectedIconTheme: const IconThemeData(color: AppColors.primary),
      unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
      destinations: items
          .map((item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              ))
          .toList(),
    );
  }
}

class _SidebarNav extends StatelessWidget {
  const _SidebarNav({required this.items, required this.selectedIndex, required this.onChanged});

  final List<AdaptiveNavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        border: Border(right: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    foreground: Paint()..shader = AppColors.primaryGradient.createShader(const Rect.fromLTWH(0, 0, 100, 30)),
                  ),
            ),
          ),
          ...List.generate(items.length, (i) {
            final item = items[i];
            final selected = i == selectedIndex;
            return ListTile(
              leading: Icon(selected ? item.selectedIcon : item.icon,
                  color: selected ? AppColors.primary : AppColors.textMuted),
              title: Text(item.label,
                  style: TextStyle(
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  )),
              selected: selected,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () => onChanged?.call(i),
            );
          }),
        ],
      ),
    );
  }
}
