import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/lab_instructor_provider.dart';
import 'package:smart_labs_mobile/providers/lab_student_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_labs_mobile/widgets/instructor/row_details.dart';

class PeopleTab extends ConsumerWidget {
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const PeopleTab({super.key, required this.lab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final studentsAsync = ref.watch(labStudentsProvider(lab.labId));
    final instructorsAsync = ref.watch(labInstructorsProvider(lab.labId));

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
                                          isDark: isDark,
                                        ),
                                      if (student.major != null)
                                        RowDetails(
                                          label: 'Major',
                                          value: student.major!,
                                          isDark: isDark,
                                        ),
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
                    child: Theme(
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
                                    color: isDark ? Colors.black : Colors.white,
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
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: (isDark ? Colors.white24 : Colors.black26),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (instructor.faculty != null)
                                  RowDetails(
                                    label: 'Faculty',
                                    value: instructor.faculty!,
                                    isDark: isDark,
                                  ),
                                if (instructor.major != null)
                                  RowDetails(
                                    label: 'Major',
                                    value: instructor.major!,
                                    isDark: isDark,
                                  ),
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
}
