import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/notification_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);
    final notifications = notificationsState.notifications;
    final isLoading = notificationsState.isLoading;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty) ...[
            IconButton(
              icon: Icon(
                Icons.done_all,
                color: isDark ? const Color(0xFFFFFF00) : Colors.blue,
              ),
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllAsRead(),
              tooltip: 'Mark all as read',
            ),
            IconButton(
              icon: Icon(
                Icons.delete_sweep,
                color: isDark ? const Color(0xFFFFFF00) : Colors.blue,
              ),
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllAsDeleted(),
              tooltip: 'Clear all',
            ),
          ],
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? const Color(0xFFFFFF00) : Colors.blue,
              ),
            )
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: TextStyle(
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: isDark ? const Color(0xFFFFFF00) : Colors.blue,
                  onRefresh: () => ref
                      .read(notificationsProvider.notifier)
                      .refreshNotifications(),
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
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
                          ref
                              .read(notificationsProvider.notifier)
                              .markAsDeleted(notification['id'].toString());
                        },
                        child: Card(
                          color: notification['isRead']
                              ? (isDark
                                  ? const Color(0xFF1C1C1C)
                                  : Colors.white)
                              : (isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.blue.shade50),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: ListTile(
                            title: Text(
                              notification['title'],
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification['message'],
                                  style: TextStyle(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeago.format(date),
                                  style: TextStyle(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: !notification['isRead']
                                ? IconButton(
                                    icon: Icon(
                                      Icons.mark_email_read,
                                      color: isDark
                                          ? const Color(0xFFFFFF00)
                                          : Colors.blue,
                                    ),
                                    onPressed: () => ref
                                        .read(notificationsProvider.notifier)
                                        .markAsRead(notification['id'].toString()),
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
