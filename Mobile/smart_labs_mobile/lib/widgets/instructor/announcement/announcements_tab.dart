import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/announcement_provider.dart';
import 'package:smart_labs_mobile/widgets/instructor/announcement/announcement_comments_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
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

class AnnouncementsTab extends ConsumerStatefulWidget {
  final Lab lab;

  const AnnouncementsTab({super.key, required this.lab});

  @override
  ConsumerState<AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends ConsumerState<AnnouncementsTab> {
  final TextEditingController _messageController = TextEditingController();
  bool _isDialogOpen = false;
  final List<File> selectedFiles = [];
  bool isAssignment = false;
  bool canSubmit = false;
  DateTime? deadline;
  TextEditingController gradeController = TextEditingController();

  void _resetFiles() {
    setState(() {
      selectedFiles.clear();
    });
  }

  Future<void> _addAnnouncement(
      List<File> files, Map<String, dynamic> data) async {
    if (data['message'].trim().isEmpty) return;

    try {
      await ref
          .read(labAnnouncementsProvider(widget.lab.labId).notifier)
          .addAnnouncement(data, files);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted successfully')),
        );
        _messageController.clear();
        _resetFiles();
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
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: isDark
                    ? const Color(0xFF1C1C1C)
                    : theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            onPressed: () {
                              _resetFiles();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black12
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.black12,
                                  ),
                                ),
                                child: TextField(
                                  controller: _messageController,
                                  maxLines: 5,
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface),
                                  decoration: InputDecoration(
                                    hintText: 'Write your announcement here...',
                                    hintStyle: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.attach_file),
                                    label: const Text('Attach Files'),
                                    onPressed: () => _showAttachmentOptions(
                                        context, setState),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                      foregroundColor:
                                          theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedFiles.isEmpty
                                          ? 'No files selected'
                                          : '${selectedFiles.length} files selected',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (selectedFiles.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: selectedFiles.length,
                                    itemBuilder: (context, index) {
                                      final file = selectedFiles[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: Chip(
                                          label:
                                              Text(file.path.split('/').last),
                                          onDeleted: () {
                                            setState(() {
                                              selectedFiles.remove(file);
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              SwitchListTile(
                                title: const Text('Is Assignment'),
                                value: isAssignment,
                                onChanged: (bool value) {
                                  setState(() {
                                    isAssignment = value;
                                    if (!value) {
                                      canSubmit = false;
                                      deadline = null;
                                      gradeController.clear();
                                    }
                                  });
                                },
                              ),
                              if (isAssignment) ...[
                                SwitchListTile(
                                  title: const Text('Allow Submissions'),
                                  value: canSubmit,
                                  onChanged: (bool value) {
                                    setState(() {
                                      canSubmit = value;
                                    });
                                  },
                                ),
                                ListTile(
                                  title: const Text('Deadline'),
                                  subtitle: Text(deadline?.toString() ??
                                      'No deadline set'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 365)),
                                      );
                                      if (date != null) {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            deadline = DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                              time.hour,
                                              time.minute,
                                            );
                                          });
                                        }
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: TextField(
                                    controller: gradeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Maximum Grade',
                                      hintText:
                                          'Enter maximum grade (e.g., 100)',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _resetFiles();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              final data = {
                                'message': _messageController.text,
                                'assignment': isAssignment,
                                'canSubmit': canSubmit,
                                'deadline': deadline?.toIso8601String(),
                                'grade': int.tryParse(gradeController.text),
                              };
                              _addAnnouncement(selectedFiles, data);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFFFFFF00)
                                  : theme.colorScheme.primary,
                              foregroundColor:
                                  isDark ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Post Announcement',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isDialogOpen = false);
      }
    }
  }

  Future<void> _showAttachmentOptions(
      BuildContext context, Function setState) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Document'),
              onTap: () async {
                Navigator.pop(context);
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowMultiple: true,
                  allowedExtensions: ['pdf', 'doc', 'docx'],
                );
                _handleFilePickerResult(result, setState);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleFilePickerResult(FilePickerResult? result, Function setState) {
    if (result != null) {
      setState(() {
        selectedFiles.addAll(
          result.paths.map((path) => File(path!)).toList(),
        );
      });
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
