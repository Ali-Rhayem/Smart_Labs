import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/user_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

final labStudentsProvider = StateNotifierProvider.family<LabStudentsNotifier,
    AsyncValue<List<User>>, String>(
  (ref, labId) => LabStudentsNotifier(labId),
);

class LabStudentsNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final String labId;
  final ApiService _apiService = ApiService();

  LabStudentsNotifier(this.labId) : super(const AsyncValue.loading()) {
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      state = const AsyncValue.loading();
      final response = await _apiService.get('/Lab/$labId/students');

      if (response['success'] != false) {
        final List<dynamic> data = response['data'];
        final students = data
            .map((json) => User(
                  id: json['id'],
                  name: json['name'],
                  email: json['email'],
                  role: json['role'],
                  major: json['major'],
                  faculty: json['faculty'],
                  imageUrl: json['image'],
                  faceIdentityVector: json['faceIdentityVector'],
                ))
            .toList();

        state = AsyncValue.data(students);
      } else {
        state = AsyncValue.error(
          'Failed to fetch students',
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addStudents(List<String> emails) async {
    try {
      final response =
          await _apiService.postRaw('/Lab/$labId/students', emails);
      if (response['success'] != false) {
        // Refresh the students list
        await fetchStudents();
      } else {
        throw Exception(response['message'] ?? 'Failed to add students');
      }
    } catch (e) {
      throw Exception('Failed to add students: $e');
    }
  }

  Future<void> removeStudent(String studentId) async {
    try {
      final response =
          await _apiService.delete('/Lab/$labId/students/$studentId');
      if (response['success'] != false) {
        // Refresh the students list
        await fetchStudents();
      } else {
        throw Exception(response['message'] ?? 'Failed to remove student');
      }
    } catch (e) {
      throw Exception('Failed to remove student: $e');
    }
  }

  void clearStudents() {
    state = const AsyncValue.data([]);
  }
}