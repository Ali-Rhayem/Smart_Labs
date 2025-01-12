import 'secure_storage.dart';

class AuthMiddleware {
  static Future<bool> isAuthenticated() async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    return token != null;
  }

  static Future<String> getInitialRoute() async {
    return await isAuthenticated() ? '/studentMain' : '/login';
  }
} 