import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/announcement_provider.dart';
import 'package:smart_labs_mobile/widgets/instructor/announcement_comments_screen.dart';
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
  static const Color kNeonAccent = Color(0xFFFFFF00);
  final TextEditingController _messageController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final announcementsAsync =
        ref.watch(labAnnouncementsProvider(widget.lab.labId));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: kNeonAccent,
            onRefresh: () => ref
                .read(labAnnouncementsProvider(widget.lab.labId).notifier)
                .fetchAnnouncements(),
            child: announcementsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (announcements) => ListView.builder(
                itemCount: announcements.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return Card(
                    color: const Color(0xFF1C1C1C),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Avatar
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: announcement.user.imageUrl !=
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // User Name
                                    Text(
                                      announcement.user.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Announcement Message
                                    Text(
                                      announcement.message,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      formatDateTime(announcement.time),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteAnnouncement(
                                    announcement.id.toString()),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final shouldRefresh = await Navigator.push<bool>(
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
                                  .read(
                                      labAnnouncementsProvider(widget.lab.labId)
                                          .notifier)
                                  .fetchAnnouncements();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.comment_outlined,
                                  size: 18,
                                  color: kNeonAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${announcement.comments.length} Comments',
                                  style: const TextStyle(
                                    color: kNeonAccent,
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
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Write an announcement...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1C1C1C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: kNeonAccent),
                onPressed: _addAnnouncement,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
