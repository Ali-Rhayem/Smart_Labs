import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/ppe_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

final ppeProvider = FutureProvider<List<PPE>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.get('/PPE');

  if (response['success'] != false) {
    final List<dynamic> data = response['data'];
    final result = data.map((json) => PPE.fromJson(json)).toList();
    return result;
  }

  throw Exception('Failed to load PPE items');
});

final ppeListProvider =
    FutureProvider.family<List<PPE>, List<String>>((ref, ppeIds) async {
  final apiService = ApiService();
  final response =
      await apiService.postRaw('/PPE/list', ppeIds.map(int.parse).toList());

  if (response['success'] != false) {
    final List<dynamic> data = response['data'];
    return data.map((json) => PPE.fromJson(json)).toList();
  }

  throw Exception('Failed to load PPE items');
});
