import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  final _apiService = ApiService();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.put('/User/change-password', {
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
      });

      if (!mounted) return;

      if (response['success']) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to change password')),
        );
      }
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
      backgroundColor: isDark ? const Color(0xFF121212) : theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Current Password',
                obscure: _obscureCurrentPassword,
                onToggleVisibility: () {
                  setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
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
                label: 'Confirm New Password',
                obscure: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFFFFEB00)
                      : theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: isDark
                      ? const Color(0xFFFFEB00).withOpacity(0.5)
                      : theme.colorScheme.primary.withOpacity(0.5),
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
                    : Text(
                        'Change Password',
                        style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
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
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white24
                : theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white24
                : theme.colorScheme.onSurface.withOpacity(0.2),
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
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
    );
  }
}