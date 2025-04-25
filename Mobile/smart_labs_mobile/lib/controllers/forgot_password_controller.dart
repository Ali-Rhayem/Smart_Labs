import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

class ForgotPasswordController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool isLoading = false;

  void dispose() {
    emailController.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<Map<String, dynamic>> resetPassword() async {
    if (!formKey.currentState!.validate()) {
      return {'success': false, 'message': 'Validation failed'};
    }

    try {
      final response = await _apiService.post(
        '/User/resetPassword',
        {'email': emailController.text.trim()},
        requiresAuth: false,
      );

      return {
        'success': response['success'],
        'message': response['message'] ?? 'Failed to reset password'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
