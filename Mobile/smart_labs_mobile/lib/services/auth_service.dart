import 'package:logger/logger.dart';
import '../utils/secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final SecureStorage _secureStorage = SecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final String? fcmToken = await _secureStorage.readFcmToken();
    final response = await _apiService.post(
      '/User/login',
      {'email': email, 'password': password, 'Fcm_token': fcmToken},
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
    await _secureStorage.deleteToken();
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
}
