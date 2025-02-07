import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/lab_instructor_provider.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/providers/lab_student_provider.dart';
import 'package:smart_labs_mobile/providers/session_provider.dart';
import '../../widgets/session_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/user_model.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';

var logger = Logger();

class InstructorLabDetailScreen extends StatelessWidget {
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);
  const InstructorLabDetailScreen({super.key, required this.lab});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            'Lab Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Implement edit lab functionality
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF121212),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabHeader(),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: TabBar(
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                labelColor: kNeonAccent,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: kNeonAccent,
                dividerColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Sessions'),
                  Tab(text: 'People'),
                  Tab(text: 'Analytics'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSessionsTab(),
                  _buildPeopleTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lab.labName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lab.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.code, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Lab Code: ${lab.labCode}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Schedule',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...lab.schedule.map((schedule) {
            String dayName = _getDayName(schedule.dayOfWeek);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$dayName:',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${schedule.startTime} - ${schedule.endTime}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final sessionsAsync = ref.watch(labSessionsProvider(lab.labId));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    if (!lab.started) {
                      await ref
                          .read(labSessionsProvider(lab.labId).notifier)
                          .startSession();
                    } else {
                      await ref
                          .read(labSessionsProvider(lab.labId).notifier)
                          .endSession();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: lab.started ? Colors.red : kNeonAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  lab.started ? 'End Session' : 'Start Session',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: kNeonAccent,
                onRefresh: () async {
                  // Explicitly refresh sessions
                  await ref
                      .read(labSessionsProvider(lab.labId).notifier)
                      .fetchSessions();
                },
                child: sessionsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: kNeonAccent),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  data: (sessions) {
                    if (sessions.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Center(
                            child: Text(
                              'No sessions available.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return SessionCard(session: session);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPeopleTab() {
    return Consumer(
      builder: (context, ref, child) {
        final studentsAsync = ref.watch(labStudentsProvider(lab.labId));
        final instructorsAsync = ref.watch(labInstructorsProvider(lab.labId));

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddStudentsDialog(context, ref),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Students'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kNeonAccent,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showAddInstructorsDialog(context, ref),
                        icon: const Icon(Icons.school),
                        label: const Text('Add Instructors'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kNeonAccent,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Students',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                    padding: const EdgeInsets.all(16),
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
                                    _buildDetailRow(
                                        'Faculty', student.faculty!),
                                  if (student.major != null)
                                    _buildDetailRow('Major', student.major!),
                                  const SizedBox(height: 8),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.end,
                                  //   children: [
                                  //     TextButton(
                                  //       onPressed: () {
                                  //         // TODO: Implement view student analytics
                                  //       },
                                  //       child: const Text(
                                  //         'View Analytics',
                                  //         style: TextStyle(color: kNeonAccent),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Instructors',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                    padding: const EdgeInsets.all(16),
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
                                    _buildDetailRow(
                                        'Faculty', instructor.faculty!),
                                  if (instructor.major != null)
                                    _buildDetailRow('Major', instructor.major!),
                                  const SizedBox(height: 8),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.end,
                                  //   children: [
                                  //     TextButton(
                                  //       onPressed: () {
                                  //         // TODO: Implement view instructor analytics
                                  //       },
                                  //       child: const Text(
                                  //         'View Analytics',
                                  //         style: TextStyle(color: kNeonAccent),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
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
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lab Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalyticCard(
            'Average Attendance',
            '85%',
            Icons.people,
            Colors.blue,
          ),
          _buildAnalyticCard(
            'PPE Compliance',
            '92%',
            Icons.health_and_safety,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1C1C1C),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(String dayOfWeek) {
    switch (dayOfWeek.toUpperCase()) {
      case 'MON':
        return 'Monday';
      case 'TUE':
        return 'Tuesday';
      case 'WED':
        return 'Wednesday';
      case 'THU':
        return 'Thursday';
      case 'FRI':
        return 'Friday';
      case 'SAT':
        return 'Saturday';
      case 'SUN':
        return 'Sunday';
      default:
        return dayOfWeek;
    }
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
                  logger.d('dialogContext.mounted: ${dialogContext.mounted}');
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
