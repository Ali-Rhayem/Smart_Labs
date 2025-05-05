import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_labs_mobile/api/firebase_api.dart';
import 'package:smart_labs_mobile/providers/theme_provider.dart';
import 'package:smart_labs_mobile/screens/instructor/instructor_dashboard.dart';
import 'package:smart_labs_mobile/screens/instructor/instructor_main_wrapper.dart';
import 'package:smart_labs_mobile/screens/login.dart';
import 'package:smart_labs_mobile/screens/student/student_dashboard.dart';
import 'package:smart_labs_mobile/screens/student/student_labs.dart';
import 'package:smart_labs_mobile/screens/student/student_main_wrapper.dart';
import 'package:smart_labs_mobile/screens/first_login.dart';

var logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (Platform.isAndroid) {
    await Permission.photos.request().then((status) {
      debugPrint('Photos permission status: $status');
    });
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  String _initialRoute = '/login';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      await FirebaseApi().initNotification(ref);
    } catch (e) {
      debugPrint("Firebase initialization error: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: MaterialApp(
        title: 'Smart Labs',
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: themeMode,
        initialRoute: _initialRoute,
        routes: {
          '/login': (context) => const LoginPage(),
          '/firstLogin': (context) => const FirstLoginScreen(),
          '/studentMain': (context) => const StudentMainWrapper(),
          '/instructorMain': (context) => const InstructorMainWrapper(),
          '/studentDashboard': (context) => const StudentDashboardScreen(),
          '/instructorDashboard': (context) =>
              const InstructorDashboardScreen(),
          '/studentLabsPage': (context) => const StudentLabsScreen(),
        },
      ),
    );
  }

  // Light theme
  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.blue.shade700,
        secondary: Colors.blue.shade500,
        surface: Colors.white,
        background: Colors.grey.shade50,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: Colors.grey.shade50,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
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
      tabBarTheme: TabBarTheme(
        labelColor: Colors.blue.shade700,
        unselectedLabelColor: Colors.black54,
        indicatorColor: Colors.blue.shade700,
      ),
    );
  }

  // Dark theme
  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFFF00), // Neon accent color
        secondary: Color(0xFFFFFF00),
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
          borderSide: BorderSide(color: Color(0xFFFFFF00)),
        ),
      ),
    );
  }
}
