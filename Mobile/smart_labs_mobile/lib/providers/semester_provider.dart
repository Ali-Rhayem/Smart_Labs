import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/semester_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

final semestersProvider = FutureProvider<List<Semester>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.get('/Semester');
  if (response['success'] != false) {
    final List<dynamic> data = response['data'];
    final semesters = data.map((json) => Semester.fromJson(json)).toList();
    // Add "No Semester" option at the beginning
    semesters.insert(
        0, Semester(id: 0, name: 'No Semester', currentSemester: false));
    return semesters;
  }

  throw Exception('Failed to load semesters');
});
