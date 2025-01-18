import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';

final labsProvider = StateNotifierProvider<LabNotifier, AsyncValue<List<Lab>>>((ref) {
  return LabNotifier();
});

class LabNotifier extends StateNotifier<AsyncValue<List<Lab>>> {
  final ApiService _apiService = ApiService();
  final SecureStorage _secureStorage = SecureStorage();

  LabNotifier() : super(const AsyncValue.loading()) {
    fetchLabs();
  }

  Future<void> fetchLabs() async {
    try {
      state = const AsyncValue.loading();
      final studentId = await _secureStorage.readId();
      
      if (studentId == null) {
        state = const AsyncValue.error('User ID not found', StackTrace.empty);
        return;
      }

      final response = await _apiService.get('/Lab/student/$studentId');

      if (response['success']) {
        final List<dynamic> labsData = response['data'];
        final labs = labsData.map((lab) => Lab(
          labId: lab['id'].toString(),
          labCode: lab['labCode'],
          labName: lab['labName'],
          description: lab['description'],
          ppe: lab['ppe']?.join(', ') ?? '',
          instructors: List<String>.from(lab['instructors'] ?? []),
          students: List<String>.from(lab['students']?.map((s) => s.toString()) ?? []),
          date: DateTime.now(),
          startTime: lab['startTime'],
          endTime: lab['endTime'],
          report: lab['report'] ?? 'N/A',
          semesterId: lab['semesterID'].toString(),
          sessions: [],
        )).toList();

        state = AsyncValue.data(labs);
      } else {
        state = AsyncValue.error(
          response['message'] ?? 'Failed to fetch labs',
          StackTrace.empty,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}