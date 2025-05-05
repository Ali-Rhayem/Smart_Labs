import 'secure_storage.dart';

class AuthMiddleware {
  static Future<bool> isAuthenticated() async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    return token != null;
  }

  static Future<String> getInitialRoute() async {
    final storage = SecureStorage();
    if (!await isAuthenticated()) {
      return '/login';
    }

    final role = await storage.readRole();
    if (role == 'instructor') {
      return '/doctorMain';
    }
    return '/studentMain';
  }
}
