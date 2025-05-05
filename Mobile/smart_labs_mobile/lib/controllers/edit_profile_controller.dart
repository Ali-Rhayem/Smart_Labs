import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../utils/secure_storage.dart';
import 'package:file_picker/file_picker.dart';

class EditProfileController {
  final SecureStorage _secureStorage = SecureStorage();
  final ApiService _apiService = ApiService();

  Future<void> pickImage(
      Function(File) onImagePicked, Function(String) onBase64Generated) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowCompression: true,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        if (await file.exists()) {
          onImagePicked(file);
          final bytes = await file.readAsBytes();
          onBase64Generated(base64Encode(bytes));
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      throw Exception('Failed to pick image: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> saveChanges({
    required GlobalKey<FormState> formKey,
    required String email,
    required String name,
    required String? selectedMajor,
    required String? selectedFaculty,
    required String? base64Image,
    required User currentUser,
  }) async {
    if (!formKey.currentState!.validate()) {
      return {'success': false, 'message': 'Validation failed'};
    }

    final id = await _secureStorage.readId();
    final role = await _secureStorage.readRole();

    final Map<String, dynamic> updateData = {
      'id': int.parse(id!),
      'email': email,
      'name': name,
      'role': role,
      'password': '12343',
      'major': selectedMajor ?? currentUser.major,
      'faculty': selectedFaculty ?? currentUser.faculty,
    };

    if (base64Image != null) {
      updateData['image'] = 'data:image/jpeg;base64,$base64Image';
    } else if (currentUser.imageUrl != null) {
      updateData['image'] = null;
    }

    final response = await _apiService.put('/User/$id', updateData);

    if (response['success']) {
      // Fetch the updated user data to ensure we have the latest information
      final userResponse = await _apiService.get('/User/$id');
      if (userResponse['success']) {
        response['data'] = userResponse['data'];
      }
    }

    return response;
  }
}
