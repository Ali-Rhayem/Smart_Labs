import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/session_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

final labSessionsProvider = StateNotifierProvider.family<LabSessionsNotifier,
    AsyncValue<List<Session>>, String>(
  (ref, labId) => LabSessionsNotifier(labId),
);

class LabSessionsNotifier extends StateNotifier<AsyncValue<List<Session>>> {
  final String labId;
  final ApiService _apiService = ApiService();

  LabSessionsNotifier(this.labId) : super(const AsyncValue.loading()) {
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    try {
      state = const AsyncValue.loading();
      final response = await _apiService.get('/Sessions/lab/$labId');
      if (response['success'] != false) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        final sessions = data
            .map((json) => Session(
                  id: json['id'].toString(),
                  labId: json['labId'].toString(),
                  date: DateTime.parse(json['date']),
                  startTime: '', // Add these if available in your API
                  endTime: '', // Add these if available in your API
                  description: '',
                  output: [],
                  report: json['report'] ?? '',
                ))
            .toList();

        state = AsyncValue.data(sessions);
      } else {
        state = AsyncValue.error(
          'Failed to fetch sessions',
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> startSession() async {
    try {
      final response = await _apiService.post('/Sessions/lab/$labId/start', {});
      if (response['success'] != false) {
        await fetchSessions();
      } else {
        throw Exception(response['message'] ?? 'Failed to start session');
      }
    } catch (e) {
      throw Exception('Failed to start session: $e');
    }
  }

  Future<void> endSession() async {
    try {
      final response = await _apiService.post('/Sessions/lab/$labId/end', {});
      if (response['success'] != false) {
        await fetchSessions();
      } else {
        throw Exception(response['message'] ?? 'Failed to end session');
      }
    } catch (e) {
      throw Exception('Failed to end session: $e');
    }
  }

  // add function to clear sessions to be called in logout
  void clearSessions() {
    state = const AsyncValue.data([]);
  }
}
