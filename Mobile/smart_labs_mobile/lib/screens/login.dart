import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/user_model.dart';
import 'package:smart_labs_mobile/providers/user_provider.dart';
import 'package:smart_labs_mobile/services/auth_service.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_labs_mobile/screens/forgot_password.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final AuthService _authService = AuthService();
  final SecureStorage _secureStorage = SecureStorage();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscured = true;
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white10
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.biotech_rounded,
                      size: 64,
                      color: isDark
                          ? const Color(0xFFFFFF00)
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Welcome Text
                  Text(
                    'Welcome to Smart Labs',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please sign in to continue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (value) => _email = value!.trim(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          label: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          onSaved: (value) => _password = value!,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password should be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFFFFFF00)
                                  : theme.colorScheme.primary,
                              foregroundColor:
                                  isDark ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: isDark ? 0 : 2,
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
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Forgot Password
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                isDark ? Colors.white70 : Colors.black54,
                          ),
                          child: const Text('Forgot Password?'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      keyboardType: keyboardType,
      obscureText: isPassword && _isObscured,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: isDark
                      ? const Color(0xFFFFFF00)
                      : theme.colorScheme.primary,
                ),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              )
            : null,
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
          ),
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final result = await _authService.login(_email, _password);

    if (!mounted) return;

    if (result['success']) {
      // Clear the last screen when logging in
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastScreen');

      final userData = result['data'];
      final String? role = await _secureStorage.readRole();
      final String? id = await _secureStorage.readId();

      final userResult = await _authService.getUserById(id!);

      if (!mounted) return;

      if (userResult['success']) {
        final userDetails = userResult['data'];
        final user = User(
          id: userDetails['id'],
          name: userDetails['name'],
          email: userDetails['email'],
          password: '',
          major: userDetails['major'],
          faculty: userDetails['faculty'],
          imageUrl: userDetails['image'],
          role: role!,
          faceIdentityVector: userDetails['faceIdentityVector'],
          firstLogin: userDetails['first_login'],
        );

        ref.read(userProvider.notifier).setUser(user);
        await ref.read(labsProvider.notifier).fetchLabs();

        Fluttertoast.showToast(
            msg: "Login successful",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);

        if (user.firstLogin) {
          Navigator.pushReplacementNamed(context, '/firstLogin');
        } else {
          await prefs.setBool('isFirstLogin', false);
          if (userData['role'] == 'instructor' || userData['role'] == 'admin') {
            Navigator.pushReplacementNamed(context, '/instructorMain');
          } else {
            Navigator.pushReplacementNamed(context, '/studentMain');
          }
        }
      } else {
        Fluttertoast.showToast(
            msg: userResult['message'] ?? 'Failed to fetch user details',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      Fluttertoast.showToast(
          msg: result['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    setState(() => _isLoading = false);
  }
}
