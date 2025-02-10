import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/models/lab_schedule.dart';
import 'package:smart_labs_mobile/services/api_service.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';

final labsProvider =
    StateNotifierProvider<LabNotifier, AsyncValue<List<Lab>>>((ref) {
  return LabNotifier();
});

class LabNotifier extends StateNotifier<AsyncValue<List<Lab>>> {
  final ApiService _apiService = ApiService();
  final SecureStorage _secureStorage = SecureStorage();

  LabNotifier() : super(const AsyncValue.loading());

  Future<void> fetchLabs() async {
    try {
      state = const AsyncValue.loading();

      final role = await _secureStorage.readRole();
      final userId = await _secureStorage.readId();

      if (userId == null) {
        state = const AsyncValue.error('User ID not found', StackTrace.empty);
        return;
      }

      // Determine the correct endpoint
      final endpoint = role == 'instructor'
          ? '/Lab/instructor/$userId'
          : '/Lab/student/$userId';

      // Make the GET request
      final response = await _apiService.get(endpoint);
      // Check server response
      if (response['success']) {
        final List<dynamic> labsData = response['data'];
        // Map each lab JSON to a Dart object
        final labs = labsData.map((lab) {
          // Safely extract the `schedule` array
          // If you only need the first schedule's time:

          // Convert ppe, instructors, students to readable formats
          final ppeList = lab['ppe'] as List<dynamic>? ?? [];
          final instructorsList = lab['instructors'] as List<dynamic>? ?? [];
          final studentsList = lab['students'] as List<dynamic>? ?? [];
          final scheduleList = lab['schedule'] as List<dynamic>? ?? [];
          final announcementsList =
              lab['announcements'] as List<dynamic>? ?? [];

          String startTime = '';
          String endTime = '';

          if (scheduleList.isNotEmpty) {
            final firstSchedule = scheduleList.first;
            startTime = firstSchedule['startTime'] ?? '';
            endTime = firstSchedule['endTime'] ?? '';
          }

          // Build the Lab model
          return Lab(
            labId: lab['id'].toString(),
            labCode: lab['labCode'],
            labName: lab['labName'],
            description: lab['description'],
            ppe: ppeList.join(', '), // e.g., "Goggles, Gloves"
            instructors: instructorsList.map((s) => s.toString()).toList(),
            students: studentsList.map((s) => s.toString()).toList(),
            schedule: (lab['schedule'] as List<dynamic>)
                .map((schedule) => LabSchedule(
                      dayOfWeek: schedule['dayOfWeek'],
                      startTime: schedule['startTime'],
                      endTime: schedule['endTime'],
                    ))
                .toList(),
            report: lab['report'] ?? 'N/A',
            semesterId: lab['semesterID'].toString(),
            sessions: [], // or map your entire schedule if needed
            started: lab['started'],
          );
        }).toList();

        // Update state with success
        state = AsyncValue.data(labs);
      } else {
        // Server says success = false
        state = AsyncValue.error(
          response['message'] ?? 'Failed to fetch labs',
          StackTrace.empty,
        );
      }
    } catch (e, stack) {
      // Catch any other errors
      state = AsyncValue.error(e, stack);
    }
  }

  void clearLabs() {
    state = const AsyncValue.data([]);
  }

  void addLab(Lab lab) {
    state.whenData((labs) {
      state = AsyncValue.data([...labs, lab]);
    });
  }
}
