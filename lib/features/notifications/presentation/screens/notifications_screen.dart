import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/domain/entities/notification.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../providers/notifications_provider.dart';

/// Notifications is a cross-module inbox — an entry can be about a task,
/// habit, goal, AI insight, achievement, or the system itself — so unlike
/// every other screen in this app it's deliberately *not* opted into any
/// single module's color/background identity here; each entry's own
/// [NotificationType] already supplies its accent color. Fixes the same
/// class of hardcoded-light-palette bugs as the other screens, and wires
/// up `AppNotification.actionRoute` — the field existed on the entity and
/// was populated in three of the four mock entries' data, but nothing in
/// the UI ever read it, so tapping a notification only ever marked it
/// read and went nowhere.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final g = GoalzyColors.of(context);

    return Scaffold(
      backgroundColor: g.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: const Text('Notifications'),
              actions: [
                if (state.unreadCount > 0)
                  TextButton(
                    onPressed: () => notifier.markAllAsRead(),
                    child: const Text('Mark all read'),
                  ),
              ],
            ),
            if (state.isLoading)
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: g.primary)),
              )
            else if (state.error != null)
              SliverFillRemaining(
                child: Center(child: Text(state.error!, style: const TextStyle(color: AppColors.danger))),
              )
            else if (state.notifications.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text('No notifications', style: Theme.of(context).textTheme.bodyLarge),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notification = state.notifications[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _NotificationTile(
                          notification: notification,
                          onTap: () {
                            notifier.markAsRead(notification.id);
                            if (notification.actionRoute != null) {
                              context.push(notification.actionRoute!);
                            }
                          },
                        ),
                      ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, duration: 300.ms, curve: Curves.easeOutCubic);
                    },
                    childCount: state.notifications.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = GoalzyColors.of(context);
    final accent = _typeColor(context, notification.type);

    return GlassCard(
      onTap: onTap,
      gradient: notification.isRead
          ? null
          : LinearGradient(colors: [g.primary.withValues(alpha: 0.12), g.chipFill]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon(notification.type), color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                            ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: g.primary, shape: BoxShape.circle),
                      ),
                    if (notification.actionRoute != null) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded, size: 16, color: g.textMuted),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification.body, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Text(
                  goalzy_date.DateUtils.formatRelative(notification.timestamp),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(BuildContext context, NotificationType type) => switch (type) {
        NotificationType.task => AppColors.warning,
        NotificationType.habit => AppColors.success,
        NotificationType.goal => GoalzyColors.of(context).primary,
        NotificationType.ai => AppColors.secondary,
        NotificationType.achievement => const Color(0xFFFFD700),
        NotificationType.system => GoalzyColors.of(context).textMuted,
      };

  IconData _typeIcon(NotificationType type) => switch (type) {
        NotificationType.task => Icons.task_alt,
        NotificationType.habit => Icons.repeat,
        NotificationType.goal => Icons.flag,
        NotificationType.ai => Icons.auto_awesome,
        NotificationType.achievement => Icons.emoji_events,
        NotificationType.system => Icons.info_outline,
      };
}
