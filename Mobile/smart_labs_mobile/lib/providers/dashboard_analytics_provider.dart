import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/dashboard_analytics_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

final dashboardAnalyticsProvider =
    FutureProvider<DashboardAnalytics>((ref) async {
  final response = await ApiService().get('/Dashboard');

  if (response['success'] == false) {
    throw Exception(
        response['message'] ?? 'Failed to fetch dashboard analytics');
  }

  return DashboardAnalytics.fromJson(response['data']);
});
