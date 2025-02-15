import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/user_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

final labInstructorsProvider = StateNotifierProvider.family<
    LabInstructorsNotifier, AsyncValue<List<User>>, String>(
  (ref, labId) => LabInstructorsNotifier(labId),
);

class LabInstructorsNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final String labId;
  final ApiService _apiService = ApiService();

  LabInstructorsNotifier(this.labId) : super(const AsyncValue.loading()) {
    fetchInstructors();
  }

  Future<void> fetchInstructors() async {
    try {
      state = const AsyncValue.loading();
      final response = await _apiService.get('/Lab/$labId/instructors');

      if (response['success'] != false) {
        final List<dynamic> data = response['data'];
        final instructors = data
            .map((json) => User(
                  id: json['id'],
                  name: json['name'],
                  email: json['email'],
                  role: json['role'],
                  major: json['major'],
                  faculty: json['faculty'],
                  imageUrl: json['image'],
                  faceIdentityVector: json['faceIdentityVector'],
                  firstLogin: json['first_login'],
                ))
            .toList();

        state = AsyncValue.data(instructors);
      } else {
        state = AsyncValue.error(
          'Failed to fetch instructors',
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addInstructors(List<String> emails) async {
    try {
      final response =
          await _apiService.postRaw('/Lab/$labId/instructors', emails);
      if (response['success'] != false) {
        await fetchInstructors();
      } else {
        throw Exception(response['message'] ?? 'Failed to add instructors');
      }
    } catch (e) {
      throw Exception('Failed to add instructors: $e');
    }
  }

  Future<void> removeInstructor(String instructorId) async {
    try {
      final response =
          await _apiService.delete('/Lab/$labId/instructors/$instructorId');
      if (response['success'] != false) {
        await fetchInstructors();
      } else {
        throw Exception(response['message'] ?? 'Failed to remove instructor');
      }
    } catch (e) {
      throw Exception('Failed to remove instructor: $e');
    }
  }

  void clearInstructors() {
    state = const AsyncValue.data([]);
  }
}