import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:smart_labs_mobile/main.dart';
import 'package:smart_labs_mobile/models/announcement_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smart_labs_mobile/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<void> addAnnouncement(
      Map<String, dynamic> data, List<File> files) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiService.baseUrl}/Lab/$labId/announcement'),
      );

      // Add all fields from data
      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add files
      for (var file in files) {
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();

        var multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          filename: file.path.split('/').last,
          contentType: file.path.toLowerCase().endsWith('.pdf')
              ? MediaType('application', 'pdf')
              : null,
        );

        request.files.add(multipartFile);
      }

      // Add auth header
      final token = await SecureStorage().getToken();
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchAnnouncements();
      } else {
        throw Exception('Failed to add announcement: $responseData');
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

  Future<void> submitAssignment(
    String announcementId,
    Map<String, dynamic> data,
    List<File> files,
  ) async {
    logger.i('submitAssignment: $announcementId, $data, $files');
    try {
      // Validate file types first
      for (var file in files) {
        final extension = file.path.split('.').last.toLowerCase();
        if (!['pdf', 'doc', 'docx'].contains(extension)) {
          throw Exception('Only PDF and Word documents are allowed');
        }
      }

      final url =
          '${_apiService.baseUrl}/Lab/$labId/assignment/$announcementId/submit';
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add data fields
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add files with proper MIME type
      for (var file in files) {
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();

        // Get file extension and set proper MIME type
        final extension = file.path.split('.').last.toLowerCase();
        final mimeType = extension == 'pdf'
            ? MediaType('application', 'pdf')
            : MediaType('application',
                'vnd.openxmlformats-officedocument.wordprocessingml.document');

        var multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          filename: file.path.split('/').last,
          contentType: mimeType,
        );

        request.files.add(multipartFile);
      }

      // Add auth header
      final token = await SecureStorage().getToken();
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchAnnouncements();
      } else {
        throw Exception('Failed to submit assignment: $responseData');
      }
    } catch (e) {
      throw Exception('Failed to submit assignment: $e');
    }
  }
}
