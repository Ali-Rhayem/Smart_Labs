import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/screens/instructor/create_lab_screen.dart';
import 'package:smart_labs_mobile/screens/instructor/instructor_dashboard.dart';
import 'package:smart_labs_mobile/screens/instructor/instructor_labs.dart';
import 'package:smart_labs_mobile/screens/notifications_screen.dart';
import 'package:smart_labs_mobile/screens/profile.dart';
import 'package:smart_labs_mobile/providers/notification_provider.dart';

class InstructorMainWrapper extends ConsumerStatefulWidget {
  const InstructorMainWrapper({super.key});

  @override
  ConsumerState<InstructorMainWrapper> createState() =>
      _InstructorMainWrapperState();
}

class _InstructorMainWrapperState extends ConsumerState<InstructorMainWrapper> {
  int _currentIndex = 0;

  // A list of pages in the same order as the BottomNavigationBar items.
  // We now have 4 items: Labs, Analytics, Messages, Profile.
  late final List<Widget> _pages = [
    const DoctorLabsScreen(),
    const InstructorDashboardScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
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
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateLabScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFFFFFF00),
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
            )
          : null,
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
              label: Text(unreadCount.toString()),
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
