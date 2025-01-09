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
      currentIndex: 0, // For now, if you always want "Labs" selected by default
      onTap: (index) {
        switch (index) {
          case 0:
            // Navigate to the Student Labs Page
            Navigator.pushReplacementNamed(context, '/studentLabsPage');
            break;
          case 1:
            // Navigate to the Student Dashboard (for "Analytics")
            Navigator.pushReplacementNamed(context, '/studentDashboard');
            break;
          case 2:
            // TODO: Navigate to "Messages" (no route yet, but if you have one, do it here)
            // Example: Navigator.pushReplacementNamed(context, '/messages');
            break;
        }
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
