import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/screens/notifications_screen.dart';
import 'package:smart_labs_mobile/screens/profile.dart';
import 'package:smart_labs_mobile/screens/student/student_dashboard.dart';
import 'package:smart_labs_mobile/screens/student/student_labs.dart';
import 'package:smart_labs_mobile/providers/notification_provider.dart';

class StudentMainWrapper extends ConsumerStatefulWidget {
  const StudentMainWrapper({super.key});

  @override
  ConsumerState<StudentMainWrapper> createState() => _StudentMainWrapperState();
}

class _StudentMainWrapperState extends ConsumerState<StudentMainWrapper> {
  int _currentIndex = 0;

  // For demonstration, we create a mock user.
  // In a real app, you might fetch this from your auth provider, or pass it in as a parameter.

  // A list of pages in the same order as the BottomNavigationBar items.
  // We now have 4 items: Labs, Analytics, Messages, Profile.
  late final List<Widget> _pages = [
    const StudentLabsScreen(), // index 0
    const StudentDashboardScreen(), // index 1
    const NotificationsScreen(),
    const ProfileScreen(), // index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(notificationsProvider).unreadCount;

    return Scaffold(
      // the current page is determined by _currentIndex
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.biotech_outlined),
            label: 'Labs',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              backgroundColor: const Color(0xFFFFFF00),
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.notifications_none),
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
