import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/main.dart';
import 'package:smart_labs_mobile/models/lab_analytics_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

final labAnalyticsProvider =
    FutureProvider.family<LabAnalytics, String>((ref, labId) async {
  final response = await ApiService().get('/Lab/$labId/analyze');
  logger.i('Response: $response');

  if (response['success'] == false) {
    throw Exception(response['message'] ?? 'Failed to fetch analytics');
  }

  final data = response['data'];

  return LabAnalytics.fromJson(data);
});
