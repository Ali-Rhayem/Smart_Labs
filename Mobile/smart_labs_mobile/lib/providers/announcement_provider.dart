import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/announcement_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

final labAnnouncementsProvider = StateNotifierProvider.family<
    LabAnnouncementsNotifier, AsyncValue<List<Announcement>>, String>(
  (ref, labId) => LabAnnouncementsNotifier(labId),
);

class LabAnnouncementsNotifier
    extends StateNotifier<AsyncValue<List<Announcement>>> {
  final String labId;
  final ApiService _apiService = ApiService();

  LabAnnouncementsNotifier(this.labId) : super(const AsyncValue.loading()) {
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      state = const AsyncValue.loading();
      final response = await _apiService.get('/Lab/$labId/announcements');

      if (response['success'] != false) {
        final List<dynamic> data = response['data'];
        final announcements =
            data.map((json) => Announcement.fromJson(json)).toList();
        state = AsyncValue.data(announcements);
      } else {
        state = AsyncValue.error(
          'Failed to fetch announcements',
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addAnnouncement(String message) async {
    try {
      final response = await _apiService.post(
        '/Lab/$labId/announcement',
        {'message': message},
      );

      if (response['success'] != false) {
        await fetchAnnouncements();
      } else {
        throw Exception(response['message'] ?? 'Failed to add announcement');
      }
    } catch (e) {
      throw Exception('Failed to add announcement: $e');
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      final response = await _apiService.delete(
        '/Lab/$labId/announcement/$announcementId',
      );

      if (response['success'] != false) {
        await fetchAnnouncements();
      } else {
        throw Exception(response['message'] ?? 'Failed to delete announcement');
      }
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  Future<void> addComment(String announcementId, String message) async {
    try {
      final response = await _apiService.post(
        '/Lab/$labId/announcement/$announcementId/comment',
        {'message': message},
      );

      if (response['success'] != false) {
        await fetchAnnouncements();
      } else {
        throw Exception(response['message'] ?? 'Failed to add comment');
      }
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }
}
