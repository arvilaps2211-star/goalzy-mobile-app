import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/entities/notification.dart';
import '../../data/repositories/mock_notification_repository.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return MockNotificationRepository();
});

class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(this._repo) : super(const NotificationsState()) {
    loadNotifications();
  }

  final NotificationRepository _repo;

  Future<void> loadNotifications() async {
    state = const NotificationsState(isLoading: true);
    try {
      final notifications = await _repo.getNotifications();
      state = NotificationsState(notifications: notifications);
    } catch (e) {
      state = NotificationsState(error: e.toString());
    }
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    state = NotificationsState(
      notifications: state.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
    );
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
    state = NotificationsState(
      notifications: state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.watch(notificationRepositoryProvider));
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});
