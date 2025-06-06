import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/models/lab_schedule.dart';
import 'package:smart_labs_mobile/models/ppe_model.dart';
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

      final endpoint = role == 'instructor'
          ? '/Lab/instructor/$userId'
          : '/Lab/student/$userId';

      final response = await _apiService.get(endpoint);

      if (response['success']) {
        final List<dynamic> labsData = response['data'];

        // Get all semester IDs (excluding 0 or empty)
        final semesterIds = labsData
            .map((lab) => lab['semesterID'].toString())
            .where((id) => id != '0' && id.isNotEmpty)
            .toSet()
            .toList();

        // Fetch all semesters in one request
        Map<String, String> semesterIdToName = {};
        if (semesterIds.isNotEmpty) {
          final semesterResponse = await _apiService.get('/Semester');
          if (semesterResponse['success']) {
            final List<dynamic> semestersData = semesterResponse['data'];
            for (var semester in semestersData) {
              semesterIdToName[semester['id'].toString()] = semester['name'];
            }
          }
        }

        // Get all unique PPE IDs from all labs
        final allPPEIds = labsData
            .expand((lab) => (lab['ppe'] as List<dynamic>? ?? []))
            .map((e) => e.toString())
            .toSet()
            .toList();

        // Fetch PPE names if there are any PPE IDs
        Map<String, String> ppeIdToName = {};
        if (allPPEIds.isNotEmpty) {
          final ppeResponse = await _apiService.postRaw(
              '/PPE/list', allPPEIds.map(int.parse).toList());
          if (ppeResponse['success']) {
            final ppeList =
                (ppeResponse['data'] as List).map((ppe) => PPE.fromJson(ppe));
            for (var ppe in ppeList) {
              ppeIdToName[ppe.id.toString()] = ppe.name;
            }
          }
        }

        final labs = labsData.map((lab) {
          final ppeIds = (lab['ppe'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();
          final ppeNames = ppeIds.map((id) => ppeIdToName[id] ?? id).toList();

          final semesterId = lab['semesterID'].toString();

          return Lab(
            labId: lab['id'].toString(),
            labCode: lab['labCode'],
            labName: lab['labName'],
            description: lab['description'],
            ppeIds: ppeIds,
            ppeNames: ppeNames,
            instructors: (lab['instructors'] as List<dynamic>? ?? [])
                .map((s) => s.toString())
                .toList(),
            students: (lab['students'] as List<dynamic>? ?? [])
                .map((s) => s.toString())
                .toList(),
            schedule: (lab['schedule'] as List<dynamic>)
                .map((schedule) => LabSchedule.fromJson(schedule))
                .toList(),
            report: lab['report'] ?? 'N/A',
            semesterId: semesterId,
            semesterName: semesterId == '0' || semesterId.isEmpty
                ? 'No Semester'
                : semesterIdToName[semesterId] ?? 'Unknown Semester',
            sessions: [],
            started: lab['started'],
            room: lab['room'],
          );
        }).toList();

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

  void clearLabs() {
    state = const AsyncValue.data([]);
  }

  void addLab(Lab lab) {
    state.whenData((labs) {
      state = AsyncValue.data([...labs, lab]);
    });
  }

  Future<Map<String, dynamic>> fetchLabById(String labId) async {
    try {
      final response = await _apiService.get('/Lab/$labId');

      if (response['success']) {
        final labData = response['data'];
        final semesterId = labData['semesterID'].toString();

        // Only fetch semester name if semesterId is valid
        String semesterName = 'No Semester';
        if (semesterId != '0' && semesterId.isNotEmpty) {
          final semesterResponse = await _apiService.get('/Semester');
          if (semesterResponse['success']) {
            final List<dynamic> semestersData = semesterResponse['data'];
            for (var semester in semestersData) {
              if (semester['id'].toString() == semesterId) {
                semesterName = semester['name'];
                break;
              }
            }
          }
        }

        // Get PPE IDs from lab data
        final ppeIds = (labData['ppe'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();

        // Fetch PPE names if there are any PPE IDs
        Map<String, String> ppeIdToName = {};
        if (ppeIds.isNotEmpty) {
          final ppeResponse = await _apiService.postRaw(
              '/PPE/list', ppeIds.map(int.parse).toList());
          if (ppeResponse['success']) {
            final ppeList =
                (ppeResponse['data'] as List).map((ppe) => PPE.fromJson(ppe));
            for (var ppe in ppeList) {
              ppeIdToName[ppe.id.toString()] = ppe.name;
            }
          }
        }

        // Convert schedules from JSON
        final scheduleList = (labData['schedule'] as List<dynamic>? ?? [])
            .map((schedule) => LabSchedule(
                  dayOfWeek: schedule['dayOfWeek'],
                  startTime: schedule['startTime'],
                  endTime: schedule['endTime'],
                ))
            .toList();

        // Create updated lab object with proper PPE names
        final updatedLab = Lab(
          labId: labData['id'].toString(),
          labCode: labData['labCode'],
          labName: labData['labName'],
          description: labData['description'],
          ppeIds: ppeIds,
          ppeNames: ppeIds.map((id) => ppeIdToName[id] ?? id).toList(),
          instructors: (labData['instructors'] as List<dynamic>? ?? [])
              .map((s) => s.toString())
              .toList(),
          students: (labData['students'] as List<dynamic>? ?? [])
              .map((s) => s.toString())
              .toList(),
          schedule: scheduleList,
          report: labData['report'] ?? 'N/A',
          semesterId: semesterId,
          semesterName: semesterName,
          sessions: [],
          started: labData['started'],
          room: labData['room'],
        );

        // Update state with the new lab data
        state.whenData((labs) {
          final index = labs.indexWhere((lab) => lab.labId == labId);
          if (index != -1) {
            final updatedLabs = List<Lab>.from(labs);
            updatedLabs[index] = updatedLab;
            state = AsyncValue.data(updatedLabs);
          }
        });

        return response;
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch lab details',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteLab(String labId) async {
    try {
      final response = await _apiService.delete('/Lab/$labId');

      if (response['success']) {
        state.whenData((labs) {
          state =
              AsyncValue.data(labs.where((lab) => lab.labId != labId).toList());
        });
        return {
          'success': true,
          'message': 'Lab deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to delete lab',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  void updateLabStatus(String labId, bool started) {
    state.whenData((labs) {
      final updatedLabs = labs.map((lab) {
        if (lab.labId == labId) {
          return Lab(
            labId: lab.labId,
            labCode: lab.labCode,
            labName: lab.labName,
            description: lab.description,
            ppeIds: lab.ppeIds,
            ppeNames: lab.ppeNames,
            room: lab.room,
            instructors: lab.instructors,
            students: lab.students,
            schedule: lab.schedule,
            report: lab.report,
            semesterId: lab.semesterId,
            semesterName: lab.semesterName,
            sessions: lab.sessions,
            started: started,
          );
        }
        return lab;
      }).toList();
      state = AsyncValue.data(updatedLabs);
    });
  }
}
