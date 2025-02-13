import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/announcement_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_labs_mobile/widgets/student/announcement/student_announcement_comments.dart';

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

class StudentAnnouncementsTab extends ConsumerStatefulWidget {
  final Lab lab;

  const StudentAnnouncementsTab({super.key, required this.lab});

  @override
  ConsumerState<StudentAnnouncementsTab> createState() => _StudentAnnouncementsTabState();
}

class _StudentAnnouncementsTabState extends ConsumerState<StudentAnnouncementsTab> {
  static const Color kNeonAccent = Color(0xFFFFFF00);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final announcementsAsync =
        ref.watch(labAnnouncementsProvider(widget.lab.labId));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: isDark ? kNeonAccent : theme.colorScheme.primary,
            onRefresh: () => ref
                .read(labAnnouncementsProvider(widget.lab.labId).notifier)
                .fetchAnnouncements(),
            child: announcementsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: isDark ? kNeonAccent : theme.colorScheme.primary,
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ),
              data: (announcements) => ListView.builder(
                itemCount: announcements.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return Card(
                    color: isDark
                        ? const Color(0xFF1C1C1C)
                        : theme.colorScheme.surface,
                    margin: const EdgeInsets.only(bottom: 10),
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
                                backgroundImage: announcement.user.imageUrl !=
                                        null
                                    ? NetworkImage(
                                        '${dotenv.env['IMAGE_BASE_URL']}/${announcement.user.imageUrl}')
                                    : const NetworkImage(
                                        'https://picsum.photos/200'),
                                backgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        .withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.comment_outlined,
                                  size: 18,
                                  color: isDark
                                      ? kNeonAccent
                                      : theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${announcement.comments.length} Comments',
                                  style: TextStyle(
                                    color: isDark
                                        ? kNeonAccent
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
        ),
      ],
    );
  }
}
