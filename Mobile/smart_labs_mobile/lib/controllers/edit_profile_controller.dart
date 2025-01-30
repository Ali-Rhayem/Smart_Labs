import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../utils/secure_storage.dart';

class EditProfileController {
  final SecureStorage _secureStorage = SecureStorage();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  Future<void> pickImage(Function(File) onImagePicked, Function(String) onBase64Generated) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      onImagePicked(imageFile);
      
      final bytes = await imageFile.readAsBytes();
      onBase64Generated(base64Encode(bytes));
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

    return await _apiService.put('/User/$id', updateData);
  }
}