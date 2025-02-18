import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/announcement_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class SubmissionsScreen extends ConsumerStatefulWidget {
  final Announcement announcement;
  final String labId;

  const SubmissionsScreen({
    super.key,
    required this.announcement,
    required this.labId,
  });

  @override
  ConsumerState<SubmissionsScreen> createState() => _SubmissionsScreenState();
}

class _SubmissionsScreenState extends ConsumerState<SubmissionsScreen> {
  static const Color kNeonAccent = Color(0xFFFFFF00);
  final ApiService _apiService = ApiService();

  Future<void> _gradeSubmission(String userId, String grade) async {
    try {
      final response = await _apiService.post(
        '/Lab/${widget.labId}/assignment/${widget.announcement.id}/user/$userId/grade/$grade',
        {},
      );

      if (mounted) {
        if (response['success']) {
          // Update the grade in the local state
          setState(() {
            final submissionIndex = widget.announcement.submissions?.indexWhere(
              (s) => s.user.id.toString() == userId,
            );
            if (submissionIndex != null && submissionIndex != -1) {
              widget.announcement.submissions![submissionIndex] =
                  widget.announcement.submissions![submissionIndex].copyWith(
                grade: int.parse(grade),
              );
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grade submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to submit grade'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGradeDialog(String userId, String studentName, int? currentGrade) {
    final TextEditingController gradeController = TextEditingController(
      text: currentGrade?.toString() ?? '',
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Grade $studentName',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Grade (max: ${widget.announcement.grade})',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: isDark ? Colors.black12 : Colors.grey[100],
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Grade: ${currentGrade ?? "Not graded"}',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? kNeonAccent : theme.colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (gradeController.text.isNotEmpty) {
                _gradeSubmission(userId, gradeController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? kNeonAccent : theme.colorScheme.primary,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Submit Grade'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndOpenFile(String fileUrl, String fileName) async {
    try {
      if (await canLaunchUrl(Uri.parse(fileUrl))) {
        await launchUrl(Uri.parse(fileUrl));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Submissions',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        elevation: 0,
      ),
      body: widget.announcement.submissions?.isEmpty ?? true
          ? Center(
              child: Text(
                'No submissions yet',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.announcement.submissions?.length ?? 0,
              itemBuilder: (context, index) {
                final submission = widget.announcement.submissions![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  color: isDark
                      ? const Color(0xFF1C1C1C)
                      : theme.colorScheme.surface,
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? Colors.white12 : Colors.black12,
                          width: 0,
                        ),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? Colors.white12 : Colors.black12,
                          width: 0,
                        ),
                      ),
                      maintainState: true,
                      leading: CircleAvatar(
                        backgroundColor:
                            isDark ? kNeonAccent : theme.colorScheme.primary,
                        child: Text(
                          submission.user.name[0].toUpperCase(),
                          style: TextStyle(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        submission.user.name,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Submitted: ${DateFormat('MMM d, y HH:mm').format(submission.submittedAt)}',
                            style: TextStyle(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            'Grade: ${submission.grade ?? "Not graded"}/${widget.announcement.grade}',
                            style: TextStyle(
                              color: submission.grade != null
                                  ? Colors.green
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                              fontWeight: submission.grade != null
                                  ? FontWeight.bold
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.grade),
                        color: isDark ? kNeonAccent : theme.colorScheme.primary,
                        onPressed: () => _showGradeDialog(
                          submission.user.id.toString(),
                          submission.user.name,
                          submission.grade,
                        ),
                      ),
                      children: [
                        if (submission.message.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              submission.message,
                              style:
                                  TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          ),
                        if (submission.files.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Submitted Files:',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...submission.files.map((file) => ListTile(
                                      leading: const Icon(Icons.attachment),
                                      title: Text(
                                        file.split('/').last,
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      onTap: () => _downloadAndOpenFile(
                                        '${dotenv.env['BASE_URL']}/$file',
                                        file.split('/').last,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
