import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'role';
  static const String _idKey = 'id';

  Future<void> storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> storeRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> readRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<void> storeId(String id) async {
    await _storage.write(key: _idKey, value: id);
  }

  Future<String?> readId() async {
    return await _storage.read(key: _idKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
