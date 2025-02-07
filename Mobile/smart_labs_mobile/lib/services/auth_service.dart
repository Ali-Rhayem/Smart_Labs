import '../utils/secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final SecureStorage _secureStorage = SecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.deleteToken();

    final fcmToken = await firebaseMessaging.getToken();

    if (fcmToken != null) {
      await _secureStorage.storeFcmToken(fcmToken);
    }

    final response = await _apiService.post(
      '/User/login',
      {
        'email': email,
        'password': password,
        'fcm_token': fcmToken
      }, // Include the token in login
      requiresAuth: false,
    );

    if (response['success']) {
      final token = response['data']['token'];
      await _secureStorage.storeToken(token);

      // Decode the token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      var id = decodedToken[
          'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
      var role = decodedToken[
          'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      await _secureStorage.storeId(id);
      await _secureStorage.storeRole(role);

      return {
        'success': true,
        'data': {
          'id': id,
          'role': role,
          // Add other fields if necessary
        },
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Login failed',
      };
    }
  }

  Future<void> logout() async {
    final firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.deleteToken();

    await _secureStorage.clearAll();
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    final response = await _apiService.get('/User/$userId');

    if (response['success']) {
      return {
        'success': true,
        'data': response['data'],
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch user details',
      };
    }
  }

  Future<Map<String, dynamic>> getNotifications(String userId) async {
    final response = await _apiService.get('/Notification/user/$userId');

    if (response['success']) {
      return {
        'success': true,
        'data': response['data'],
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch notifications',
      };
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(
      String notificationId) async {
    final response =
        await _apiService.put('/Notification/mark-as-read/$notificationId', {});

    if (response['success']) {
      return {
        'success': true,
        'data': response['data'],
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to mark notification as read',
      };
    }
  }

  Future<Map<String, dynamic>> markNotificationAsDeleted(
      String notificationId) async {
    final response = await _apiService
        .put('/Notification/mark-as-deleted/$notificationId', {});

    if (response['success']) {
      return {
        'success': true,
        'data': response['data'],
      };
    } else {
      return {
        'success': false,
        'message':
            response['message'] ?? 'Failed to mark notification as deleted',
      };
    }
  }

  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    final response =
        await _apiService.put('/Notification/mark-all-as-read', {});

    if (response['success']) {
      return {
        'success': true,
        'data': response['data'],
      };
    } else {
      return {
        'success': false,
        'message':
            response['message'] ?? 'Failed to mark all notifications as read',
      };
    }
  }

  Future<Map<String, dynamic>> markAllNotificationsAsDeleted() async {
    final response =
        await _apiService.put('/Notification/mark-all-as-deleted', {});

    if (response['success']) {
      return {
        'success': true,
        'data': response['data'],
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ??
            'Failed to mark all notifications as deleted',
      };
    }
  }

   Future<List<Map<String, dynamic>>?> getUserNotifications(String userId) async {
    try {
      final response = await _apiService.get('/Notification/user/$userId');

      if (response['success']) {
        final List<dynamic> data = response['data'];
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
