import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/models/user_model.dart';
import 'package:smart_labs_mobile/providers/lab_instructor_provider.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/providers/lab_student_provider.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';
import 'package:smart_labs_mobile/widgets/instructor/row_details.dart';

class PeopleTab extends ConsumerWidget {
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const PeopleTab({super.key, required this.lab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(labStudentsProvider(lab.labId));
    final instructorsAsync = ref.watch(labInstructorsProvider(lab.labId));

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
                const Text(
                  'Students',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showAddStudentsDialog(context, ref),
                  icon: const Icon(Icons.person_add),
                ),
              ],
            ),
          ),

          studentsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: kNeonAccent),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            data: (students) {
              if (students.isEmpty) {
                return Center(
                  child: Text(
                    'No students enrolled',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
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
                    color: const Color(0xFF1C1C1C),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: kNeonAccent,
                        child: Text(
                          student.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        student.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        student.email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        onPressed: () =>
                            _showRemoveStudentDialog(context, ref, student),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (student.faculty != null)
                                RowDetails(
                                    label: 'Faculty', value: student.faculty!),
                              if (student.major != null)
                                RowDetails(
                                    label: 'Major', value: student.major!),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
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
                const Text(
                  'Instructors',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showAddInstructorsDialog(context, ref),
                  icon: const Icon(Icons.person_add),
                ),
              ],
            ),
          ),
          instructorsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: kNeonAccent),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            data: (instructors) {
              if (instructors.isEmpty) {
                return Center(
                  child: Text(
                    'No instructors enrolled',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
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
                    color: const Color(0xFF1C1C1C),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: kNeonAccent,
                        child: Text(
                          instructor.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        instructor.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        instructor.email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        onPressed: () => _showRemoveInstructorDialog(
                            context, ref, instructor),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (instructor.faculty != null)
                                RowDetails(
                                    label: 'Faculty',
                                    value: instructor.faculty!),
                              if (instructor.major != null)
                                RowDetails(
                                    label: 'Major', value: instructor.major!),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
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

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title:
            const Text('Add Students', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter student emails (one per line):',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailsController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'student1@example.com\nstudent2@example.com',
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
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
            child: const Text('Add', style: TextStyle(color: kNeonAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _showRemoveStudentDialog(
      BuildContext context, WidgetRef ref, User student) async {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title:
            const Text('Remove Student', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove ${student.name} from this lab?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
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

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Add Instructors',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter instructor emails (one per line):',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailsController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'instructor1@example.com\ninstructor2@example.com',
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: kNeonAccent),
                ),
                filled: true,
                fillColor: Colors.black12,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: Instructors will receive an email invitation to join the lab.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
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
                    const SnackBar(
                      content: Text('Instructors added successfully'),
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
              backgroundColor: kNeonAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Add Instructors'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRemoveInstructorDialog(
      BuildContext context, WidgetRef ref, User instructor) async {
    final secureStorage = SecureStorage();
    final currentUserId = await secureStorage.readId();

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text('Remove Instructor',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove ${instructor.name} from this lab?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
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
