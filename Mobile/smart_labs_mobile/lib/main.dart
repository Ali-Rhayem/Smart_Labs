import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/api/firebase_api.dart';
import 'package:smart_labs_mobile/screens/instructor/instructor_dashboard.dart';
import 'package:smart_labs_mobile/screens/instructor/instructor_main_wrapper.dart';
import 'package:smart_labs_mobile/screens/login.dart';
import 'package:smart_labs_mobile/screens/student/student_main_wrapper.dart';
import 'package:smart_labs_mobile/screens/student/student_dashboard.dart';
import 'package:smart_labs_mobile/screens/student/student_labs.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_labs_mobile/providers/theme_provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotification();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // Example color for accent (neon‐like yellow in dark mode).
  // Adjust as you see fit (e.g., #CDFF00 or #FFFF00).
  static const Color kNeonAccent = Color(0xFFFFFF00);

  // Build a light theme
  ThemeData buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.blue.shade700,
        secondary: const Color(0xFF2196F3),
        surface: Colors.white,
        background: Colors.grey.shade50,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: Colors.grey.shade50,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade700),
        ),
        labelStyle: const TextStyle(color: Colors.black87),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Build a dark theme
  ThemeData buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: kNeonAccent,
        secondary: kNeonAccent,
        surface: Color(0xFF1C1C1C),
      ),
      scaffoldBackgroundColor: Colors.black,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1C1C1C),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kNeonAccent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Smart Labs',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/studentMain': (context) => const StudentMainWrapper(),
        '/instructorMain': (context) => const InstructorMainWrapper(),
        '/studentDashboard': (context) => const StudentDashboardScreen(),
        '/instructorDashboard': (context) => const InstructorDashboardScreen(),
        '/studentLabsPage': (context) => const StudentLabsScreen(),
      },
    );
  }
}
