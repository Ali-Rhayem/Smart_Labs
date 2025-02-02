import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/user_model.dart';
import 'package:smart_labs_mobile/screens/profile.dart';
import 'package:smart_labs_mobile/screens/student/student_dashboard.dart';
import 'package:smart_labs_mobile/screens/student/student_labs.dart';

class StudentMainWrapper extends StatefulWidget {
  const StudentMainWrapper({super.key});

  @override
  State<StudentMainWrapper> createState() => _StudentMainWrapperState();
}

class _StudentMainWrapperState extends State<StudentMainWrapper> {
  int _currentIndex = 0;

  // For demonstration, we create a mock user.
  // In a real app, you might fetch this from your auth provider, or pass it in as a parameter.

  // A list of pages in the same order as the BottomNavigationBar items.
  // We now have 4 items: Labs, Analytics, Messages, Profile.
  late final List<Widget> _pages = [
    const StudentLabsScreen(),         // index 0
    const StudentDashboardScreen(),    // index 1
    const StudentLabsScreen(),         // index 2 (Messages placeholder)
    const ProfileScreen(),    // index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // the current page is determined by _currentIndex
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.biotech_outlined),
            label: 'Labs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
