import '../utils/secure_storage.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final SecureStorage _secureStorage = SecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    print("login");
    final response = await _apiService.post(
      '/User/login',
      {'email': email, 'password': password},
      requiresAuth: false,
    );
    print(response);

    if (response['success']) {
      final data = response['data'];
      await _secureStorage.storeToken(data['token']);
      return {
        'success': true,
        'user': data['user'],
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
}
