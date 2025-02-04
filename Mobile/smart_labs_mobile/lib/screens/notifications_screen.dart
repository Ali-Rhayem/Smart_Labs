import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/user_provider.dart';
import 'package:smart_labs_mobile/services/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final AuthService _authService = AuthService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final user = ref.read(userProvider);
    if (user != null) {
      final result = await _authService.getNotifications(user.id.toString());
      if (result['success']) {
        setState(() {
          _notifications = result['data'];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    final result = await _authService.markNotificationAsRead(notificationId);
    if (result['success']) {
      await _fetchNotifications();
    }
  }

  Future<void> _markAsDeleted(String notificationId) async {
    final result = await _authService.markNotificationAsDeleted(notificationId);
    if (result['success']) {
      await _fetchNotifications();
    }
  }

  Future<void> _markAllAsRead() async {
    final result = await _authService.markAllNotificationsAsRead();
    if (result['success']) {
      await _fetchNotifications();
    }
  }

  Future<void> _markAllAsDeleted() async {
    final result = await _authService.markAllNotificationsAsDeleted();
    if (result['success']) {
      await _fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.done_all, color: Color(0xFFFFFF00)),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Color(0xFFFFFF00)),
              onPressed: _markAllAsDeleted,
              tooltip: 'Clear all',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFFF00)),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFFFFFF00),
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final DateTime date =
                          DateTime.parse(notification['date']);

                      return Dismissible(
                        key: Key(notification['id'].toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _markAsDeleted(notification['id'].toString());
                        },
                        child: Card(
                          color: notification['isRead']
                              ? const Color(0xFF1C1C1C)
                              : const Color(0xFF2C2C2C),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: ListTile(
                            title: Text(
                              notification['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification['message'],
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeago.format(date),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: !notification['isRead']
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.mark_email_read,
                                      color: Color(0xFFFFFF00),
                                    ),
                                    onPressed: () => _markAsRead(
                                        notification['id'].toString()),
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
