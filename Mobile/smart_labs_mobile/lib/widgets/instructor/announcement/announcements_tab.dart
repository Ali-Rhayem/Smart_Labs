import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/announcement_provider.dart';
import 'package:smart_labs_mobile/widgets/instructor/announcement/announcement_comments_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String formatDateTime(DateTime dateTime) {
  final hour = dateTime.hour > 12
      ? dateTime.hour - 12
      : dateTime.hour == 0
          ? 12
          : dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final year = dateTime.year;

  return "$month/$day/$year, $hour:$minute $period";
}

class AnnouncementsTab extends ConsumerStatefulWidget {
  final Lab lab;

  const AnnouncementsTab({super.key, required this.lab});

  @override
  ConsumerState<AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends ConsumerState<AnnouncementsTab> {
  final TextEditingController _messageController = TextEditingController();
  bool _isDialogOpen = false;

  Future<void> _addAnnouncement() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await ref
          .read(labAnnouncementsProvider(widget.lab.labId).notifier)
          .addAnnouncement(_messageController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted successfully')),
        );
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteAnnouncement(String announcementId) async {
    try {
      await ref
          .read(labAnnouncementsProvider(widget.lab.labId).notifier)
          .deleteAnnouncement(announcementId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showAddAnnouncementDialog(BuildContext context) async {
    setState(() => _isDialogOpen = true);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor:
                isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Announcement',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black12 : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: 5,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Write your announcement here...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          _addAnnouncement();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFFFFFF00)
                              : theme.colorScheme.primary,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Post Announcement',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isDialogOpen = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final announcementsAsync =
        ref.watch(labAnnouncementsProvider(widget.lab.labId));

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              RefreshIndicator(
                color: isDark
                    ? const Color(0xFFFFFF00)
                    : theme.colorScheme.primary,
                onRefresh: () => ref
                    .read(labAnnouncementsProvider(widget.lab.labId).notifier)
                    .fetchAnnouncements(),
                child: announcementsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (announcements) => ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: announcements.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      return Card(
                        color: isDark
                            ? const Color(0xFF1C1C1C)
                            : theme.colorScheme.surface,
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: isDark ? 0 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, left: 16, right: 16, bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: announcement
                                                .user.imageUrl !=
                                            null
                                        ? NetworkImage(
                                            '${dotenv.env['IMAGE_BASE_URL']}/${announcement.user.imageUrl}')
                                        : const NetworkImage(
                                            'https://picsum.photos/200'),
                                    backgroundColor: Colors.grey[800],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          announcement.user.name,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          announcement.message,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteAnnouncement(
                                        announcement.id.toString()),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                final shouldRefresh =
                                    await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AnnouncementCommentsScreen(
                                      announcement: announcement,
                                      labId: widget.lab.labId,
                                    ),
                                  ),
                                );

                                if (shouldRefresh == true && mounted) {
                                  await ref
                                      .read(labAnnouncementsProvider(
                                              widget.lab.labId)
                                          .notifier)
                                      .fetchAnnouncements();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      formatDateTime(announcement.time),
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.comment_outlined,
                                      size: 18,
                                      color: isDark
                                          ? const Color(0xFFFFFF00)
                                          : theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${announcement.comments.length} Comments',
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFFFFFF00)
                                            : theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: !_isDialogOpen
                      ? FloatingActionButton(
                          key: const ValueKey<bool>(true),
                          onPressed: () => _showAddAnnouncementDialog(context),
                          backgroundColor: isDark
                              ? const Color(0xFFFFFF00)
                              : theme.colorScheme.primary,
                          child: Icon(
                            Icons.add,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey<bool>(false)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
