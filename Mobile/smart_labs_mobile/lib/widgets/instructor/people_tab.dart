import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/models/user_model.dart';
import 'package:smart_labs_mobile/providers/lab_instructor_provider.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/providers/lab_student_provider.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';
import 'package:smart_labs_mobile/widgets/instructor/row_details.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_labs_mobile/widgets/email_input_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PeopleTab extends ConsumerStatefulWidget {
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const PeopleTab({super.key, required this.lab});

  @override
  ConsumerState<PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends ConsumerState<PeopleTab> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(labStudentsProvider(widget.lab.labId));
    final instructorsAsync =
        ref.watch(labInstructorsProvider(widget.lab.labId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              children: [
                Text(
                  'Students',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditMode = !_isEditMode;
                    });
                  },
                  icon: Icon(
                    _isEditMode ? Icons.edit_off : Icons.edit,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                if (_isEditMode)
                  IconButton(
                    onPressed: () => _showAddStudentsDialog(context, ref),
                    icon: Icon(
                      Icons.person_add,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
              ],
            ),
          ),
          studentsAsync.when(
            loading: () => Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error: $error',
                style: TextStyle(
                  color: theme.colorScheme.onBackground.withValues(alpha: 0.7),
                ),
              ),
            ),
            data: (students) {
              if (students.isEmpty) {
                return Center(
                  child: Text(
                    'No students enrolled',
                    style: TextStyle(
                      color:
                          theme.colorScheme.onBackground.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    color: isDark
                        ? const Color(0xFF1C1C1C)
                        : theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 1,
                      ),
                    ),
                    elevation: isDark ? 0 : 1,
                    child: student.faculty == null && student.major == null
                        ? ListTile(
                            leading: (student.imageUrl != null &&
                                    student.imageUrl!.isNotEmpty)
                                ? CircleAvatar(
                                    radius: 24,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: ClipOval(
                                      child: Image.network(
                                        '${dotenv.env['IMAGE_BASE_URL']}/${student.imageUrl}',
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return SizedBox(
                                            width: 48,
                                            height: 48,
                                            child: CircleAvatar(
                                              radius: 24,
                                              backgroundColor:
                                                  theme.colorScheme.primary,
                                              child: Text(
                                                student.name[0].toUpperCase(),
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 24,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: Text(
                                      student.name[0].toUpperCase(),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            title: Text(
                              student.name,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              student.email,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            trailing: _isEditMode
                                ? IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () => _showRemoveStudentDialog(
                                        context, ref, student),
                                  )
                                : null,
                          )
                        : Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              leading: (student.imageUrl != null &&
                                      student.imageUrl!.isNotEmpty)
                                  ? CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      child: ClipOval(
                                        child: Image.network(
                                          '${dotenv.env['IMAGE_BASE_URL']}/${student.imageUrl}',
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: CircleAvatar(
                                                radius: 24,
                                                backgroundColor:
                                                    theme.colorScheme.primary,
                                                child: Text(
                                                  student.name[0].toUpperCase(),
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      child: Text(
                                        student.name[0].toUpperCase(),
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                              title: Text(
                                student.name,
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface),
                              ),
                              subtitle: Text(
                                student.email,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              trailing: _isEditMode
                                  ? IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red),
                                      onPressed: () => _showRemoveStudentDialog(
                                          context, ref, student),
                                    )
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: (isDark
                                      ? Colors.white24
                                      : Colors.black26),
                                  width: 1,
                                ),
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (student.faculty != null)
                                        RowDetails(
                                            label: 'Faculty',
                                            value: student.faculty!,
                                            isDark: isDark),
                                      if (student.major != null)
                                        RowDetails(
                                            label: 'Major',
                                            value: student.major!,
                                            isDark: isDark),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  );
                },
              );
            },
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Instructors',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isEditMode)
                  IconButton(
                    onPressed: () => _showAddInstructorsDialog(context, ref),
                    icon: Icon(
                      Icons.person_add,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
              ],
            ),
          ),
          instructorsAsync.when(
            loading: () => Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error: $error',
                style: TextStyle(
                  color: theme.colorScheme.onBackground.withValues(alpha: 0.7),
                ),
              ),
            ),
            data: (instructors) {
              if (instructors.isEmpty) {
                return Center(
                  child: Text(
                    'No instructors enrolled',
                    style: TextStyle(
                      color:
                          theme.colorScheme.onBackground.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                itemCount: instructors.length,
                itemBuilder: (context, index) {
                  final instructor = instructors[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    color: isDark
                        ? const Color(0xFF1C1C1C)
                        : theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 1,
                      ),
                    ),
                    elevation: isDark ? 0 : 1,
                    child: instructor.faculty == null &&
                            instructor.major == null
                        ? ListTile(
                            leading: (instructor.imageUrl != null &&
                                    instructor.imageUrl!.isNotEmpty)
                                ? CircleAvatar(
                                    radius: 24,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: ClipOval(
                                      child: Image.network(
                                        '${dotenv.env['IMAGE_BASE_URL']}/${instructor.imageUrl}',
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return SizedBox(
                                            width: 48,
                                            height: 48,
                                            child: CircleAvatar(
                                              radius: 24,
                                              backgroundColor:
                                                  theme.colorScheme.primary,
                                              child: Text(
                                                instructor.name[0]
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 24,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: Text(
                                      instructor.name[0].toUpperCase(),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            title: Text(
                              instructor.name,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              instructor.email,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            trailing: _isEditMode
                                ? IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _showRemoveInstructorDialog(
                                            context, ref, instructor),
                                  )
                                : null,
                          )
                        : Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              leading: (instructor.imageUrl != null &&
                                      instructor.imageUrl!.isNotEmpty)
                                  ? CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      child: ClipOval(
                                        child: Image.network(
                                          '${dotenv.env['IMAGE_BASE_URL']}/${instructor.imageUrl}',
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: CircleAvatar(
                                                radius: 24,
                                                backgroundColor:
                                                    theme.colorScheme.primary,
                                                child: Text(
                                                  instructor.name[0]
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      child: Text(
                                        instructor.name[0].toUpperCase(),
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                              title: Text(
                                instructor.name,
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface),
                              ),
                              subtitle: Text(
                                instructor.email,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              trailing: _isEditMode
                                  ? IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _showRemoveInstructorDialog(
                                              context, ref, instructor),
                                    )
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: (isDark
                                      ? Colors.white24
                                      : Colors.black26),
                                  width: 1,
                                ),
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (instructor.faculty != null)
                                        RowDetails(
                                            label: 'Faculty',
                                            value: instructor.faculty!,
                                            isDark: isDark),
                                      if (instructor.major != null)
                                        RowDetails(
                                            label: 'Major',
                                            value: instructor.major!,
                                            isDark: isDark),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAddStudentsDialog(
      BuildContext context, WidgetRef ref) async {
    bool isLoading = false;
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) =>
            EmailInputDialog(
          title: 'Add Students',
          isLoading: isLoading,
          onSubmit: (emails) async {
            setDialogState(() => isLoading = true);
            try {
              await ref
                  .read(labStudentsProvider(widget.lab.labId).notifier)
                  .addStudents(emails);
              if (dialogContext.mounted) {
                Fluttertoast.showToast(
                  msg: 'Students added successfully',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                Navigator.pop(dialogContext);
              }
            } catch (e) {
              if (dialogContext.mounted) {
                Fluttertoast.showToast(
                  msg: e.toString(),
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            } finally {
              if (dialogContext.mounted) {
                setDialogState(() => isLoading = false);
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _showRemoveStudentDialog(
      BuildContext context, WidgetRef ref, User student) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        title: Text(
          'Remove Student',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to remove ${student.name} from this lab?',
          style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(labStudentsProvider(widget.lab.labId).notifier)
                    .removeStudent(student.id.toString());
                if (dialogContext.mounted) {
                  Fluttertoast.showToast(
                    msg: 'Student removed successfully',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  Navigator.pop(dialogContext);
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  Fluttertoast.showToast(
                    msg: e.toString(),
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddInstructorsDialog(
      BuildContext context, WidgetRef ref) async {
    bool isLoading = false;
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) =>
            EmailInputDialog(
          title: 'Add Instructors',
          isLoading: isLoading,
          onSubmit: (emails) async {
            setDialogState(() => isLoading = true);
            try {
              await ref
                  .read(labInstructorsProvider(widget.lab.labId).notifier)
                  .addInstructors(emails);
              if (dialogContext.mounted) {
                Fluttertoast.showToast(
                  msg: 'Instructors added successfully',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                Navigator.pop(dialogContext);
              }
            } catch (e) {
              if (dialogContext.mounted) {
                Fluttertoast.showToast(
                  msg: e.toString(),
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            } finally {
              if (dialogContext.mounted) {
                setDialogState(() => isLoading = false);
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _showRemoveInstructorDialog(
      BuildContext context, WidgetRef ref, User instructor) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secureStorage = SecureStorage();
    final currentUserId = await secureStorage.readId();

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        title: Text(
          'Remove Instructor',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to remove ${instructor.name} from this lab?',
          style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(labInstructorsProvider(widget.lab.labId).notifier)
                    .removeInstructor(instructor.id.toString());

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);

                if (instructor.id.toString() == currentUserId) {
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext)
                      .popUntil((route) => route.isFirst);

                  if (!dialogContext.mounted) return;
                  await ref.read(labsProvider.notifier).fetchLabs();
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  Fluttertoast.showToast(
                    msg: e.toString(),
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
