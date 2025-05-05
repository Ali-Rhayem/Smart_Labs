class NotificationsState {
  final bool isLoading;
  final List<dynamic> notifications;

  NotificationsState({
    required this.isLoading,
    required this.notifications,
  });

  int get unreadCount => notifications.where((n) => !n['isRead']).length;

  NotificationsState copyWith({
    bool? isLoading,
    List<dynamic>? notifications,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
    );
  }
}
