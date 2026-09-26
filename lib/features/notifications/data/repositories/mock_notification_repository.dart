import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository() : _notifications = List.from(MockData.notifications);

  List<AppNotification> _notifications;

  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(
      _notifications..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
    );
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
  }

  @override
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    return _notifications.where((n) => !n.isRead).length;
  }
}
