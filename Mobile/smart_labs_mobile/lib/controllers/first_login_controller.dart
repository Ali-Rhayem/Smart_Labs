import 'dart:io';
import '../models/user_model.dart';
import '../services/api_service.dart';

class FirstLoginController {
  final ApiService _apiService = ApiService();

  String getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<Map<String, dynamic>> submitFirstLogin({
    required User currentUser,
    required String name,
    required String password,
    required String confirmPassword,
    required String? selectedMajor,
    required String? selectedFaculty,
    File? imageFile,
    String? base64Image,
  }) async {
    try {
      final response = await _apiService.post('/User/firstlogin', {
        'id': currentUser.id,
        'name': name,
        'password': password,
        'confirmPassword': confirmPassword,
        'major': selectedMajor,
        'faculty': selectedFaculty,
        'image': base64Image != null && imageFile != null
            ? 'data:${getMimeType(imageFile.path)};base64,$base64Image'
            : "",
        'first_login': false,
        'email': currentUser.email,
      });

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }

      final userResponse = await _apiService.get('/User/${currentUser.id}');
      if (!userResponse['success']) {
        throw Exception(
            userResponse['message'] ?? 'Failed to fetch updated user data');
      }

      return userResponse;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  User createUpdatedUser(Map<String, dynamic> userDetails, User currentUser) {
    return User(
      id: userDetails['id'],
      name: userDetails['name'],
      email: userDetails['email'],
      password: '',
      major: userDetails['major'],
      faculty: userDetails['faculty'],
      imageUrl: userDetails['image'],
      role: currentUser.role,
      faceIdentityVector: userDetails['faceIdentityVector'],
      firstLogin: false,
    );
  }
}