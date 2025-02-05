import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/notification_state.dart';
import 'package:smart_labs_mobile/providers/user_provider.dart';
import 'package:smart_labs_mobile/services/auth_service.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final user = ref.watch(userProvider);
  final userId = user?.id.toString() ?? '';
  return NotificationsNotifier(
    authService: AuthService(),
    userId: userId,
  );
});

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final AuthService authService;
  final String userId;

  NotificationsNotifier({required this.authService, required this.userId})
      : super(NotificationsState(isLoading: true, notifications: [])) {
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (userId.isNotEmpty) {
      final result = await authService.getNotifications(userId);
      if (result['success']) {
        state = state.copyWith(
          isLoading: false,
          notifications: result['data'],
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    // Optimistically update the notification to be marked as read
    final updatedNotifications = state.notifications.map((notification) {
      if (notification['id'].toString() == notificationId) {
        return {...notification, 'isRead': true};
      }
      return notification;
    }).toList();
    state = state.copyWith(notifications: updatedNotifications);

    final result = await authService.markNotificationAsRead(notificationId);
    if (!result['success']) {
      // In case of failure, you might want to revert the change or refetch
      await _fetchNotifications();
    }
  }

  Future<void> markAsDeleted(String notificationId) async {
    // Optimistically remove the notification from the list
    final updatedNotifications = state.notifications
        .where(
            (notification) => notification['id'].toString() != notificationId)
        .toList();
    state = state.copyWith(notifications: updatedNotifications);

    final result = await authService.markNotificationAsDeleted(notificationId);
    if (!result['success']) {
      await _fetchNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    final updatedNotifications = state.notifications
        .map((notification) => {...notification, 'isRead': true})
        .toList();
    state = state.copyWith(notifications: updatedNotifications);

    final result = await authService.markAllNotificationsAsRead();
    if (!result['success']) {
      await _fetchNotifications();
    }
  }

  Future<void> markAllAsDeleted() async {
    // Optimistically clear all notifications
    state = state.copyWith(notifications: []);

    final result = await authService.markAllNotificationsAsDeleted();
    if (!result['success']) {
      await _fetchNotifications();
    }
  }

  Future<void> refreshNotifications() async {
    state = state.copyWith(isLoading: true);
    await _fetchNotifications();
  }

  void addNotification(Map<String, dynamic> notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
    );
  }
}
