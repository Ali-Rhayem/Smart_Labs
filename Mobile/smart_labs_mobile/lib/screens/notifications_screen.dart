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

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.done_all, color: Color(0xFFFFFF00)),
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllAsRead(),
              tooltip: 'Mark all as read',
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Color(0xFFFFFF00)),
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllAsDeleted(),
              tooltip: 'Clear all',
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFFF00)),
            )
          : notifications.isEmpty
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
