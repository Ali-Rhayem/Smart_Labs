import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/announcement_provider.dart';
import 'package:smart_labs_mobile/providers/faculty_provider.dart';
import 'package:smart_labs_mobile/providers/lab_analytics_provider.dart';
import 'package:smart_labs_mobile/providers/lab_instructor_provider.dart';
import 'package:smart_labs_mobile/providers/lab_student_provider.dart';
import 'package:smart_labs_mobile/providers/notification_provider.dart';
import 'package:smart_labs_mobile/providers/room_provider.dart';
import 'package:smart_labs_mobile/providers/semester_provider.dart';
import 'package:smart_labs_mobile/providers/session_provider.dart';

void resetAllProviders(WidgetRef ref) {
  // // Clear user data
  // ref.read(userProvider.notifier).clearUser();

  // // Clear labs data
  // ref.read(labsProvider.notifier).clearLabs();

  // // Get current labs to clear their related providers
  // final labs = ref.read(labsProvider).value ?? [];

  // // Clear data for each lab
  // for (final lab in labs) {
  //   // Clear sessions
  //   ref.read(labSessionsProvider(lab.labId).notifier).clearSessions();

  //   // Clear instructors
  //   ref.read(labInstructorsProvider(lab.labId).notifier).clearInstructors();

  //   // Clear students
  //   ref.read(labStudentsProvider(lab.labId).notifier).clearStudents();
  // }

  // Invalidate provider families to ensure fresh data on next use
  ref.invalidate(labStudentsProvider);
  ref.invalidate(labInstructorsProvider);
  ref.invalidate(labSessionsProvider);
  ref.invalidate(labAnnouncementsProvider);
  ref.invalidate(notificationsProvider);
  ref.invalidate(semestersProvider);
  ref.invalidate(labAnalyticsProvider);
  ref.invalidate(facultiesProvider);
  ref.invalidate(roomsProvider);
}
