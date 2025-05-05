import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/faculty_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

final facultiesProvider = FutureProvider<List<Faculty>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.get('/Faculty');
  
  if (response['success'] != false) {
    final List<dynamic> data = response['data'];
    final result = data.map((json) => Faculty.fromJson(json)).toList();
    return result;
  }
  
  throw Exception('Failed to load faculties');
});