import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/announcement_model.dart';
import 'package:smart_labs_mobile/models/comment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/announcement_provider.dart';
import 'package:smart_labs_mobile/providers/user_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:file_picker/file_picker.dart';

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
  final List<File> selectedFiles = [];
  final TextEditingController submissionMessageController =
      TextEditingController();

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
        // Create a new comment with local data since we got a 204
        final currentUser = ref.read(userProvider);
        final newComment = Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          user: currentUser!,
          message: _commentController.text.trim(),
          time: DateTime.now(),
        );

        setState(() {
          widget.announcement.comments.add(newComment);
        });

        // Clear the input field
        _commentController.clear();

        // Scroll to the bottom after the state has been updated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        // Show success message
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

  void _resetSubmission() {
    setState(() {
      selectedFiles.clear();
      submissionMessageController.clear();
    });
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          selectedFiles.addAll(result.paths.map((path) => File(path!)));
        });
        // Force rebuild of the bottom sheet
        if (mounted) {
          Navigator.pop(context);
          _showSubmissionDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  void _showSubmissionDialog() {
    // Check if user has already submitted
    final hasSubmitted = widget.announcement.submissions?.any(
          (submission) => submission.submitted == true,
        ) ??
        false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color:
                  isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hasSubmitted ? 'Your Submission' : 'Submit Assignment',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _resetSubmission();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (hasSubmitted) ...[
                        // Show previous submissions
                        ...widget.announcement.submissions!
                            .where((submission) => submission.submitted)
                            .map((submission) => Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Submitted on: ${formatDateTime(submission.submittedAt)}',
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                        if (submission.message.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            submission.message,
                                            style: TextStyle(
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                        if (submission.files.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Submitted Files:',
                                            style: TextStyle(
                                              color:
                                                  theme.colorScheme.onSurface,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...submission.files.map(
                                            (file) => ListTile(
                                              leading: Icon(_getFileIcon(file)),
                                              title: Text(file.split('/').last),
                                              onTap: () async {
                                                final fileUrl =
                                                    '${dotenv.env['BASE_URL']}/$file';
                                                await _downloadAndOpenFile(
                                                  fileUrl,
                                                  file.split('/').last,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                        if (submission.grade != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Grade: ${submission.grade}',
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ] else ...[
                        // Show submission form
                        TextField(
                          controller: submissionMessageController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Attachments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (selectedFiles.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'No files selected',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: selectedFiles.length,
                            itemBuilder: (context, index) {
                              final file = selectedFiles[index];
                              final fileName = file.path.split('/').last;
                              return StatefulBuilder(
                                builder: (context, setListState) {
                                  return ListTile(
                                    leading: Icon(_getFileIcon(fileName)),
                                    title: Text(fileName),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          selectedFiles.removeAt(index);
                                        });
                                        setListState(() {});
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Add Files (PDF, DOC, Images)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!hasSubmitted)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedFiles.isEmpty
                                ? null
                                : () async {
                                    try {
                                      await ref
                                          .read(labAnnouncementsProvider(
                                                  widget.labId)
                                              .notifier)
                                          .submitAssignment(
                                            widget.announcement.id.toString(),
                                            {
                                              'message':
                                                  submissionMessageController
                                                      .text
                                            },
                                            selectedFiles,
                                          );
                                      if (mounted) {
                                        // Create a new submission with local data
                                        final currentUser =
                                            ref.read(userProvider);
                                        final newSubmission = Submission(
                                          userId: currentUser!.id,
                                          user: currentUser,
                                          message:
                                              submissionMessageController.text,
                                          files: selectedFiles
                                              .map((file) =>
                                                  file.path.split('/').last)
                                              .toList(),
                                          submittedAt: DateTime.now(),
                                          submitted: true,
                                        );

                                        setState(() {
                                          if (widget.announcement.submissions ==
                                              null) {
                                            widget.announcement.submissions =
                                                [];
                                          }
                                          widget.announcement.submissions!
                                              .add(newSubmission);
                                        });

                                        _resetSubmission();
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Assignment submitted successfully'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error submitting assignment: $e'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? kNeonAccent
                                  : theme.colorScheme.primary,
                              foregroundColor:
                                  isDark ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      backgroundColor:
          isDark ? const Color(0xFF121212) : theme.colorScheme.background,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark ? const Color(0xFF2C2C2C) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isDark ? kNeonAccent : theme.colorScheme.primary,
                    ),
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
                if (widget.announcement.isAssignment) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment,
                                    color: isDark
                                        ? kNeonAccent
                                        : theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Assignment',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.announcement.canSubmit)
                              ElevatedButton(
                                onPressed: _showSubmissionDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget
                                              .announcement.submissions
                                              ?.any((submission) =>
                                                  submission.submitted ==
                                                  true) ??
                                          false
                                      ? Colors.green
                                      : isDark
                                          ? kNeonAccent
                                          : theme.colorScheme.primary,
                                  foregroundColor:
                                      isDark ? Colors.black : Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.announcement.submissions?.any(
                                                  (submission) =>
                                                      submission.submitted ==
                                                      true) ??
                                              false
                                          ? Icons.check_circle
                                          : Icons.upload_file,
                                      size: 18,
                                      color:
                                          isDark ? Colors.black : Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.announcement.submissions?.any(
                                                  (submission) =>
                                                      submission.submitted ==
                                                      true) ??
                                              false
                                          ? 'View Submission'
                                          : 'Submit',
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (widget.announcement.deadline != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.timer,
                                  size: 16,
                                  color: isDark
                                      ? kNeonAccent
                                      : theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Deadline: ${formatDateTime(widget.announcement.deadline!)}',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (widget.announcement.submissions?.any(
                              (submission) => submission.grade != null,
                            ) ??
                            false) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.grade,
                                  size: 16,
                                  color: isDark
                                      ? kNeonAccent
                                      : theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Grade: ${widget.announcement.submissions!.firstWhere((s) => s.grade != null).grade}/${widget.announcement.grade}',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (widget.announcement.files.isNotEmpty) ...[
                  const SizedBox(height: 16),
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
                                  '${dotenv.env['BASE_URL']}${widget.announcement.files[index]}';
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
                                    color: isDark
                                        ? kNeonAccent
                                        : theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    fileName,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
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
                            color: (isDark
                                    ? kNeonAccent
                                    : theme.colorScheme.primary)
                                .withValues(alpha: 0.5),
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
                                color: (isDark
                                        ? kNeonAccent
                                        : theme.colorScheme.primary)
                                    .withValues(alpha: 0.5),
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
                                                backgroundColor: isDark
                                                    ? Colors.grey[800]
                                                    : Colors.grey[200],
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
                                          Text(
                                            formatDateTime(comment.time),
                                            style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.5),
                                              fontSize: 12,
                                            ),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey[900] : theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.1),
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
}
