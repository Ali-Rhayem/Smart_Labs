import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/controllers/edit_profile_controller.dart';
import 'package:smart_labs_mobile/models/faculty_model.dart';
import 'package:smart_labs_mobile/widgets/edit_profile_widgets.dart';
import 'package:smart_labs_mobile/providers/faculty_provider.dart';
import 'package:smart_labs_mobile/providers/user_provider.dart';
import 'package:smart_labs_mobile/services/api_service.dart';
import 'dart:io';

class FirstLoginScreen extends ConsumerStatefulWidget {
  const FirstLoginScreen({super.key});

  @override
  ConsumerState<FirstLoginScreen> createState() => _FirstLoginScreenState();
}

class _FirstLoginScreenState extends ConsumerState<FirstLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _controller = EditProfileController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  File? _imageFile;
  String? _base64Image;
  String? _selectedFaculty;
  String? _selectedMajor;
  List<String> _availableMajors = [];

  @override
  void dispose() {
    _nameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateFaculty(String? value, List<Faculty> faculties) {
    setState(() {
      _selectedFaculty = value;
      _selectedMajor = null;
      _availableMajors = faculties
          .firstWhere(
            (f) => f.faculty == value,
            orElse: () => Faculty(id: 0, faculty: '', major: []),
          )
          .major;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update password
      // final passwordResponse = await _apiService.put('/User/change-password', {
      //   'currentPassword': '12343', // Default password
      //   'newPassword': _newPasswordController.text,
      // });

      // if (!passwordResponse['success']) {
      //   throw Exception(passwordResponse['message'] ?? 'Failed to change password');
      // }

      // Update profile
      final user = ref.read(userProvider);
      if (user == null) throw Exception('User not found');

      // final response = await _apiService.put('/User/update', {
      //   'id': user.id,
      //   'email': user.email,
      //   'name': _nameController.text,
      //   'role': user.role,
      //   'password': _newPasswordController.text,
      //   'major': _selectedMajor,
      //   'faculty': _selectedFaculty,
      //   'image': _base64Image,
      //   'isFirstLogin': false,
      // });

      if (!mounted) return;

      // if (response['success']) {
      // Update user provider and navigate to main screen
      final updatedUser = user.copyWith(
        // name: _nameController.text,
        // major: _selectedMajor,
        // faculty: _selectedFaculty,
        // imageUrl: response['data']['image'],
        isFirstLogin: false,
      );
      ref.read(userProvider.notifier).setUser(updatedUser);

      if (user.role == 'instructor') {
        Navigator.pushReplacementNamed(context, '/instructorMain');
      } else {
        Navigator.pushReplacementNamed(context, '/studentMain');
      }
      // } else {
      //   throw Exception(response['message'] ?? 'Failed to update profile');
      // }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileImageWidget(
                imageFile: _imageFile,
                userImageUrl: null,
                onImagePick: () async {
                  try {
                    await _controller.pickImage(
                      (file) => setState(() => _imageFile = file),
                      (base64) => _base64Image = base64,
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                labelText: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'New Password',
                obscure: _obscureNewPassword,
                onToggleVisibility: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                obscure: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ref.watch(facultiesProvider).when(
                    data: (faculties) => FacultyMajorDropdowns(
                      selectedFaculty: _selectedFaculty,
                      selectedMajor: _selectedMajor,
                      availableMajors: _availableMajors,
                      onFacultyChanged: (value) =>
                          _updateFaculty(value, faculties),
                      onMajorChanged: (value) =>
                          setState(() => _selectedMajor = value),
                      faculties: faculties,
                      userFaculty: null,
                      userMajor: null,
                    ),
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? const Color(0xFFFFEB00)
                            : theme.colorScheme.primary,
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error loading faculties: $error',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFFFFEB00)
                      : theme.colorScheme.primary,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.black : Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Complete Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFFFEB00) : theme.colorScheme.primary,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: isDark ? const Color(0xFFFFEB00) : theme.colorScheme.primary,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator,
    );
  }
}
