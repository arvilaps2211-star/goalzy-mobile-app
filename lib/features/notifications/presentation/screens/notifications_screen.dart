import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/domain/entities/notification.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
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
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
                            onTap: () => notifier.markAsRead(notification.id),
                          ),
                        );
                      },
                      childCount: state.notifications.length,
                    ),
                  ),
                ),
            ],
          ),
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
    return GlassCard(
      onTap: onTap,
      gradient: notification.isRead
          ? null
          : LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.12),
                AppColors.glassFill,
              ],
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _typeColor(notification.type).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon(notification.type), color: _typeColor(notification.type), size: 20),
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
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
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

  Color _typeColor(NotificationType type) => switch (type) {
        NotificationType.task => AppColors.warning,
        NotificationType.habit => AppColors.success,
        NotificationType.goal => AppColors.primary,
        NotificationType.ai => AppColors.secondary,
        NotificationType.achievement => const Color(0xFFFFD700),
        NotificationType.system => AppColors.textMuted,
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
