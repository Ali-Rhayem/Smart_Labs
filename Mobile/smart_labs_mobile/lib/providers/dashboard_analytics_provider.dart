import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/dashboard_analytics_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

final dashboardAnalyticsProvider = StateNotifierProvider<
    DashboardAnalyticsNotifier, AsyncValue<DashboardAnalytics>>((ref) {
  return DashboardAnalyticsNotifier();
});

class DashboardAnalyticsNotifier
    extends StateNotifier<AsyncValue<DashboardAnalytics>> {
  DashboardAnalyticsNotifier() : super(const AsyncValue.loading()) {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      state = const AsyncValue.loading();
      final response = await ApiService().get('/Dashboard');

      if (response['success'] == false) {
        throw Exception(
            response['message'] ?? 'Failed to fetch dashboard analytics');
      }

      state = AsyncValue.data(DashboardAnalytics.fromJson(response['data']));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clearData() {
    state = const AsyncValue.loading();
  }
}
