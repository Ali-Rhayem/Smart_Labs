import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/screens/doctor/doctor_dashboard.dart';
import 'package:smart_labs_mobile/screens/login.dart';
import 'package:smart_labs_mobile/screens/student/student_dashboard.dart';
import 'package:smart_labs_mobile/screens/student/student_labs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
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
        secondary: kNeonAccent,
      ),
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade700),
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Labs',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      // You can switch this to ThemeMode.light or ThemeMode.dark
      // to force a particular theme. Or keep it system-driven:
      themeMode: ThemeMode.dark,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/studentDashboard': (context) => const StudentDashboardScreen(),
        '/doctorDashboard': (context) => const DoctorDashboardScreen(),
        '/studentLabsPage': (context) =>const StudentLabsScreen(),
      },
    );
  }
}
