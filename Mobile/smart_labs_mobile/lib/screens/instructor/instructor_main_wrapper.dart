import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/screens/instructor/create_lab_screen.dart';
import 'package:smart_labs_mobile/screens/instructor/instructor_dashboard.dart';
import 'package:smart_labs_mobile/screens/instructor/instructor_labs.dart';
import 'package:smart_labs_mobile/screens/profile.dart';

class InstructorMainWrapper extends StatefulWidget {
  const InstructorMainWrapper({super.key});

  @override
  State<InstructorMainWrapper> createState() => _InstructorMainWrapperState();
}

class _InstructorMainWrapperState extends State<InstructorMainWrapper> {
  int _currentIndex = 0;

  // A list of pages in the same order as the BottomNavigationBar items.
  // We now have 4 items: Labs, Analytics, Messages, Profile.
  late final List<Widget> _pages = [
    const DoctorLabsScreen(),         // index 0
    const InstructorDashboardScreen(),    // index 1
    const DoctorLabsScreen(),         // index 2 (Messages placeholder)
    const ProfileScreen(),   // index 3
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
