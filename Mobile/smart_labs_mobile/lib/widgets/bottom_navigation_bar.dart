import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});
  static const Color kNeonAccent = Color(0xFFFFFF00);
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1C1C1C),
      selectedItemColor: kNeonAccent,
      unselectedItemColor: Colors.white.withValues(alpha: 0.7),
      currentIndex: 0, // 0 = labs, for example
      onTap: (index) {
        // TODO: handle navigation to other pages
      },
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
          icon: Icon(Icons.message_outlined),
          label: 'Messages',
        ),
      ],
    );
  }
  
}