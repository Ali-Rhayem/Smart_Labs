import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/announcement_model.dart';
import 'package:smart_labs_mobile/models/comment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/announcement_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_labs_mobile/screens/instructor/submissions_screen.dart';

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

class AnnouncementCommentsScreen extends ConsumerStatefulWidget {
  final Announcement announcement;
  final String labId;

  const AnnouncementCommentsScreen({
    super.key,
    required this.announcement,
    required this.labId,
  });

  @override
  ConsumerState<AnnouncementCommentsScreen> createState() =>
      _AnnouncementCommentsScreenState();
}

class _AnnouncementCommentsScreenState
    extends ConsumerState<AnnouncementCommentsScreen> {
  static const Color kNeonAccent = Color(0xFFFFFF00);
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? kNeonAccent : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        elevation: 0,
        actions: [
          if (widget.announcement.isAssignment)
            IconButton(
              icon: const Icon(Icons.assignment),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubmissionsScreen(
                    announcement: widget.announcement,
                    labId: widget.labId,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      backgroundColor:
          isDark ? const Color(0xFF121212) : theme.colorScheme.background,
      body: Column(
        children: [
          // Announcement card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark ? const Color(0xFF2C2C2C) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.announcement.message,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: accentColor),
                    const SizedBox(width: 4),
                    Text(
                      formatDateTime(widget.announcement.time),
                      style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.announcement.files.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.announcement.files.length,
                      itemBuilder: (context, index) {
                        final fileName =
                            widget.announcement.files[index].split('/').last;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () async {
                              final fileUrl =
                                  '${dotenv.env['BASE_URL']}/${widget.announcement.files[index]}';
                              await _downloadAndOpenFile(fileUrl, fileName);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      isDark ? Colors.white24 : Colors.black12,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getFileIcon(fileName),
                                    size: 16,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    fileName,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Comments list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.announcement.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.announcement.comments[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 2,
                            height: 100,
                            color: accentColor.withValues(alpha: 0.5),
                            margin: const EdgeInsets.only(left: 11),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 12,
                                height: 2,
                                margin: const EdgeInsets.only(top: 20),
                                color: accentColor.withValues(alpha: 0.5),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    color: isDark
                                        ? const Color(0xFF2C2C2C)
                                        : theme.colorScheme.surface,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundImage: comment
                                                            .user.imageUrl !=
                                                        null
                                                    ? NetworkImage(
                                                        '${dotenv.env['IMAGE_BASE_URL']}/${comment.user.imageUrl}')
                                                    : const NetworkImage(
                                                        'https://picsum.photos/200'),
                                                backgroundColor:
                                                    Colors.grey[800],
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                comment.user.name,
                                                style: TextStyle(
                                                  color: theme
                                                      .colorScheme.onSurface,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            comment.message,
                                            style: TextStyle(
                                              color:
                                                  theme.colorScheme.onSurface,
                                              fontSize: 16,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time,
                                                  size: 14, color: accentColor),
                                              const SizedBox(width: 4),
                                              Text(
                                                formatDateTime(comment.time),
                                                style: TextStyle(
                                                  color: theme
                                                      .colorScheme.onSurface
                                                      .withValues(alpha: 0.6),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Comment input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey[900] : theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color:
                              isDark ? kNeonAccent : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: Icon(
                    Icons.send_rounded,
                    color: isDark ? kNeonAccent : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await ref
          .read(labAnnouncementsProvider(widget.labId).notifier)
          .addComment(
            widget.announcement.id.toString(),
            _commentController.text.trim(),
          );

      if (mounted) {
        final newComment = Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          user: widget.announcement.user,
          message: _commentController.text.trim(),
          time: DateTime.now(),
        );

        setState(() {
          widget.announcement.comments.add(newComment);
        });

        _commentController.clear();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully')),
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

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _downloadAndOpenFile(String fileUrl, String fileName) async {
    try {
      final Dio dio = Dio();
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getTemporaryDirectory();
      }

      final String filePath = '${directory.path}/$fileName';

      // Show initial download notification
      const androidDetails = AndroidNotificationDetails(
        'download_channel',
        'File Downloads',
        channelDescription: 'Shows file download progress',
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: 100,
        progress: 0,
        ongoing: true,
        autoCancel: false,
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        'Downloading $fileName',
        'Download starting...',
        notificationDetails,
      );

      await dio.download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) async {
          if (total != -1) {
            final progress = (received / total * 100).toInt();

            // Update progress notification
            final androidProgressDetails = AndroidNotificationDetails(
              'download_channel',
              'File Downloads',
              channelDescription: 'Shows file download progress',
              importance: Importance.low,
              priority: Priority.low,
              showProgress: true,
              maxProgress: 100,
              progress: progress,
              ongoing: true,
              autoCancel: false,
            );

            final progressNotificationDetails = NotificationDetails(
              android: androidProgressDetails,
              iOS: const DarwinNotificationDetails(),
            );

            await flutterLocalNotificationsPlugin.show(
              0,
              'Downloading $fileName',
              '$progress% completed',
              progressNotificationDetails,
            );
          }
        },
      );

      // Show completion notification
      const completedAndroidDetails = AndroidNotificationDetails(
        'download_channel',
        'File Downloads',
        channelDescription: 'Shows file download progress',
        importance: Importance.high,
        priority: Priority.high,
      );

      const completedNotificationDetails = NotificationDetails(
        android: completedAndroidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        1,
        'Download Complete',
        '$fileName has been downloaded',
        completedNotificationDetails,
      );

      // Try to open the file
      final file = File(filePath);
      if (await file.exists()) {
        await OpenFilex.open(filePath);
      }
    } catch (e) {
      debugPrint("Error downloading file: $e");

      // Show error notification
      const errorAndroidDetails = AndroidNotificationDetails(
        'download_channel',
        'File Downloads',
        channelDescription: 'Shows file download progress',
        importance: Importance.high,
        priority: Priority.high,
      );

      const errorNotificationDetails = NotificationDetails(
        android: errorAndroidDetails,
        iOS: const DarwinNotificationDetails(),
      );

      await flutterLocalNotificationsPlugin.show(
        2,
        'Download Failed',
        'Failed to download $fileName: $e',
        errorNotificationDetails,
      );
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content:
            const Text('Are you sure you want to delete this announcement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(labAnnouncementsProvider(widget.labId).notifier)
            .deleteAnnouncement(widget.announcement.id.toString());

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

extension ColorExtension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
