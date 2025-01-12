import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class AuthService {
  final String baseUrl = 'YOUR_API_BASE_URL';
  final SecureStorage _secureStorage = SecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userData = data['user'];
        
        // Store the token
        await _secureStorage.storeToken(token);
        
        return {
          'success': true,
          'user': userData,
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid credentials',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error',
      };
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }
} 