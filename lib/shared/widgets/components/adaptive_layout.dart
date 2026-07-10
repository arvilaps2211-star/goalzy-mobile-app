import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    this.centerActionIndex,
    this.onCenterAction,
    this.appBar,
  });

  final Widget body;
  final List<AdaptiveNavItem>? navigationItems;
  final int selectedIndex;
  final ValueChanged<int>? onNavigationChanged;
  final int? centerActionIndex;
  final VoidCallback? onCenterAction;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final items = navigationItems ?? [];
    final g = GoalzyColors.of(context);

    return Scaffold(
      extendBody: true,
      appBar: appBar,
      backgroundColor: g.background,
      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (responsive.isDesktop && items.isNotEmpty)
              _SidebarNav(items: items, selectedIndex: selectedIndex, onChanged: onNavigationChanged, centerActionIndex: centerActionIndex, onCenterAction: onCenterAction)
            else if (responsive.isTablet && items.isNotEmpty)
              _RailNav(items: items, selectedIndex: selectedIndex, onChanged: onNavigationChanged),
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
      bottomNavigationBar: responsive.isPhone && items.isNotEmpty
          ? _FloatingBottomNav(
              items: items,
              selectedIndex: selectedIndex,
              onChanged: onNavigationChanged ?? (_) {},
              centerActionIndex: centerActionIndex,
              onCenterAction: onCenterAction,
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

class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.centerActionIndex,
    this.onCenterAction,
  });

  final List<AdaptiveNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final int? centerActionIndex;
  final VoidCallback? onCenterAction;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final centerIndex = centerActionIndex ?? (items.length ~/ 2);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.paddingOf(context).bottom + 12),
      child: Container(
        height: AppConstants.navBarHeight + 8,
        decoration: BoxDecoration(
          color: g.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: g.border),
          boxShadow: [
            BoxShadow(color: g.shadow, blurRadius: 32, offset: const Offset(0, 12), spreadRadius: -8),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            if (i == centerIndex) {
              return Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -18),
                    child: _CenterAiButton(onTap: onCenterAction ?? () => onChanged(i)),
                  ),
                ),
              );
            }

            final item = items[i];
            final selected = i == selectedIndex;
            return Expanded(
              child: _NavItem(
                item: item,
                selected: selected,
                onTap: () => onChanged(i),
              ),
            );
          }),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, curve: Curves.easeOutCubic);
  }
}

class _CenterAiButton extends StatelessWidget {
  const _CenterAiButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: g.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: g.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: 2.seconds,
          curve: Curves.easeInOut,
        );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.item, required this.selected, required this.onTap});

  final AdaptiveNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? g.primary.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              selected ? item.selectedIcon : item.icon,
              color: selected ? g.primary : g.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? g.primary : g.textMuted,
            ),
          ),
        ],
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
    final g = GoalzyColors.of(context);
    return NavigationRail(
      backgroundColor: g.surface,
      selectedIndex: selectedIndex,
      onDestinationSelected: onChanged,
      labelType: NavigationRailLabelType.all,
      indicatorColor: g.primary.withValues(alpha: 0.12),
      selectedIconTheme: IconThemeData(color: g.primary),
      unselectedIconTheme: IconThemeData(color: g.textMuted),
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
  const _SidebarNav({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.centerActionIndex,
    this.onCenterAction,
  });

  final List<AdaptiveNavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final int? centerActionIndex;
  final VoidCallback? onCenterAction;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: g.surface,
        border: Border(right: BorderSide(color: g.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(28),
            child: Text(AppConstants.appName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: g.primary, fontWeight: FontWeight.w800)),
          ),
          ...List.generate(items.length, (i) {
            final item = items[i];
            final selected = i == selectedIndex;
            if (i == centerActionIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: g.primary, child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20)),
                  title: Text('AI Assistant', style: TextStyle(color: g.textPrimary, fontWeight: FontWeight.w600)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onTap: onCenterAction ?? () => onChanged?.call(i),
                ),
              );
            }
            return ListTile(
              leading: Icon(selected ? item.selectedIcon : item.icon, color: selected ? g.primary : g.textMuted),
              title: Text(item.label, style: TextStyle(color: selected ? g.textPrimary : g.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
              selected: selected,
              selectedTileColor: g.primary.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onTap: () => onChanged?.call(i),
            );
          }),
        ],
      ),
    );
  }
}