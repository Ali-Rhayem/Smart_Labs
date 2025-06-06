import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_labs_mobile/main.dart';
import '../utils/secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final SecureStorage _secureStorage = SecureStorage();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await _secureStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    logger.i('post: $endpoint, body: $body');
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(body),
      );
      logger.w('response: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      if (response.statusCode == 204) {
        return {'success': true};
      }

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response body',
          'statusCode': response.statusCode,
        };
      }

      final body = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': body};
      } else {
        return {
          'success': false,
          'message': body['errors'] ?? body['message'] ?? 'Request failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to process response: $e',
        'statusCode': response.statusCode,
      };
    }
  }

  Future<Map<String, dynamic>> postRaw(
    String endpoint,
    dynamic body, {
    bool requiresAuth = true,
  }) async {
    logger.i('postRaw: $endpoint, body: $body');
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
