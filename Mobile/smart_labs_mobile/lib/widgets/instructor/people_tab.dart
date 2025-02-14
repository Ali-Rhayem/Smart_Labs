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

class PeopleTab extends ConsumerWidget {
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const PeopleTab({super.key, required this.lab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(labStudentsProvider(lab.labId));
    final instructorsAsync = ref.watch(labInstructorsProvider(lab.labId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       Expanded(
          //         child: ElevatedButton.icon(
          //           onPressed: () => _showAddStudentsDialog(context, ref),
          //           icon: const Icon(Icons.person_add),
          //           label: const Text('Add Students'),
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: kNeonAccent,
          //             foregroundColor: Colors.black,
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 16),
          //       Expanded(
          //         child: ElevatedButton.icon(
          //           onPressed: () => _showAddInstructorsDialog(context, ref),
          //           icon: const Icon(Icons.school),
          //           label: const Text('Add Instructors'),
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: kNeonAccent,
          //             foregroundColor: Colors.black,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
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
            data: (students) {
              if (students.isEmpty) {
                return Center(
                  child: Text(
                    'No students enrolled',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
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
                            leading: student.imageUrl != null &&
                                    student.imageUrl!.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      '${dotenv.env['IMAGE_BASE_URL']}/${student.imageUrl}',
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: isDark
                                        ? kNeonAccent
                                        : theme.colorScheme.primary,
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
                                    .withOpacity(0.7),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () => _showRemoveStudentDialog(
                                  context, ref, student),
                            ),
                          )
                        : Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              leading: student.imageUrl != null &&
                                      student.imageUrl!.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        '${dotenv.env['IMAGE_BASE_URL']}/${student.imageUrl}',
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: isDark
                                          ? kNeonAccent
                                          : theme.colorScheme.primary,
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
                                      .withOpacity(0.7),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                onPressed: () => _showRemoveStudentDialog(
                                    context, ref, student),
                              ),
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
            data: (instructors) {
              if (instructors.isEmpty) {
                return Center(
                  child: Text(
                    'No instructors enrolled',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
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
                            leading: instructor.imageUrl != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      '${dotenv.env['IMAGE_BASE_URL']}/${instructor.imageUrl}',
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: isDark
                                        ? kNeonAccent
                                        : theme.colorScheme.primary,
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
                                    .withOpacity(0.7),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () => _showRemoveInstructorDialog(
                                  context, ref, instructor),
                            ),
                          )
                        : Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              leading: instructor.imageUrl != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        '${dotenv.env['IMAGE_BASE_URL']}/${instructor.imageUrl}',
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: isDark
                                          ? kNeonAccent
                                          : theme.colorScheme.primary,
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
                                      .withOpacity(0.7),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                onPressed: () => _showRemoveInstructorDialog(
                                    context, ref, instructor),
                              ),
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
    final TextEditingController emailsController = TextEditingController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        title: Text(
          'Add Students',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter student emails (one per line):',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailsController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'student1@example.com\nstudent2@example.com',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? kNeonAccent : theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final emails = emailsController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              if (emails.isEmpty) return;

              try {
                await ref
                    .read(labStudentsProvider(lab.labId).notifier)
                    .addStudents(emails);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text(
              'Add',
              style: TextStyle(
                color: isDark ? kNeonAccent : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
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
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(labStudentsProvider(lab.labId).notifier)
                    .removeStudent(student.id.toString());
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(e.toString())),
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
    final TextEditingController emailsController = TextEditingController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        title: Text(
          'Add Instructors',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter instructor emails (one per line):',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailsController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'instructor1@example.com\ninstructor2@example.com',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? kNeonAccent : theme.colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.black12 : theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Note: Instructors will receive an email invitation to join the lab.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final emails = emailsController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              if (emails.isEmpty) return;

              try {
                await ref
                    .read(labInstructorsProvider(lab.labId).notifier)
                    .addInstructors(emails);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: const Text('Instructors added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? kNeonAccent : theme.colorScheme.primary,
              foregroundColor:
                  isDark ? Colors.black : theme.colorScheme.onPrimary,
            ),
            child: const Text('Add Instructors'),
          ),
        ],
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
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(labInstructorsProvider(lab.labId).notifier)
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
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(e.toString())),
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
