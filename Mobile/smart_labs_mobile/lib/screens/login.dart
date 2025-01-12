import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/user_model.dart';
import 'package:smart_labs_mobile/providers/user_provider.dart';
import 'package:smart_labs_mobile/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscured = true;
  String _email = '';
  String _password = '';

  // Use a bright neon-yellow color to match the “Interview” button from the mockup
  // You can tweak this to be more lime‐like (#CDFF00) or more yellow (#FFFF00).
  static const Color kAccentColor = Color(0xFFFFFF00);

  @override
  Widget build(BuildContext context) {
    // We’ll create a custom theme for dark mode with neon accents.
    final theme = Theme.of(context).copyWith(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            // The primary color is used for widgets like icons, titles, etc.
            // using a bright neon‐yellow here:
            primary: kAccentColor,
            // A dark background
            surface: Colors.black,
            // Text on background will be white
            onSurface: Colors.white,
            // Text on primary (accent) color
            onPrimary: Colors.black,
          ),
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,  // default text color
            displayColor: Colors.white,
          ),
      // ElevatedButtonTheme with neon accent
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentColor,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade900,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: kAccentColor,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: kAccentColor),
        ),
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo or Title
                    Icon(
                      Icons.biotech_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Welcome to Smart Labs',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please sign in to continue',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // The Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
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
                            onSaved: (value) => _email = value!.trim(),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            obscureText: _isObscured,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscured
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscured = !_isObscured;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password should be at least 6 characters long';
                              }
                              return null;
                            },
                            onSaved: (value) => _password = value!,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Sign In',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Possibly a "Forgot Password?" link or a "Sign Up" link
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password navigation
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();

      // Dummy role determination:
      bool isDoctor = _email.toLowerCase().contains('doctor');

      // Navigate to the respective dashboard
      if (isDoctor) {
        Navigator.pushReplacementNamed(context, '/doctorMain');
      } else {
        Navigator.pushReplacementNamed(context, '/studentMain');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logging in as $_email...')),
      );
    }
  }

  // Future<void> _submitForm() async {
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();
      
  //     setState(() => _isLoading = true);
      
  //     final result = await _authService.login(_email, _password);
      
  //     setState(() => _isLoading = false);
      
  //     if (result['success']) {
  //       // Create user object from response data
  //       final userData = result['user'];
  //       final user = User(
  //         id: userData['id'],
  //         name: userData['name'],
  //         email: userData['email'],
  //         role: userData['role'],
  //         password: userData['password'],
  //         major: userData['major'],
  //         faculty: userData['faculty'],
  //         imageUrl: userData['imageUrl'],
  //         faceIdentityVector: userData['faceIdentityVector'],
  //         // ... other fields
  //       );
        
  //       // Update user provider
  //       Provider.of<UserProvider>(context, listen: false).setUser(user);
        
  //       // Navigate based on role
  //       if (user.role == 'doctor') {
  //         Navigator.pushReplacementNamed(context, '/doctorMain');
  //       } else {
  //         Navigator.pushReplacementNamed(context, '/studentMain');
  //       }
  //     } else {
  //       // Show error message
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(result['message'])),
  //       );
  //     }
  //   }
  // }
}
