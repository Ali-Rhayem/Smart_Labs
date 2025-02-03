import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import '../../widgets/session_card.dart';

class InstructorLabDetailScreen extends StatelessWidget {
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);
  const InstructorLabDetailScreen({super.key, required this.lab});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            'Lab Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Implement edit lab functionality
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF121212),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabHeader(),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: TabBar(
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                labelColor: kNeonAccent,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: kNeonAccent,
                dividerColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Sessions'),
                  Tab(text: 'Students'),
                  Tab(text: 'Analytics'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSessionsTab(),
                  _buildStudentsTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lab.labName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lab.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.code, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Lab Code: ${lab.labCode}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Schedule',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...lab.schedule.map((schedule) {
            String dayName = _getDayName(schedule.dayOfWeek);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$dayName:',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${schedule.startTime} - ${schedule.endTime}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    final sessions = lab.sessions;
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          'No sessions available.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionCard(session: session);
      },
    );
  }

  Widget _buildStudentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lab.students.length,
      itemBuilder: (context, index) {
        final student = lab.students[index];
        return Card(
          color: const Color(0xFF1C1C1C),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: kNeonAccent,
              child: Icon(Icons.person, color: Colors.black),
            ),
            title: Text(
              student,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // TODO: Implement student options menu
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lab Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalyticCard(
            'Average Attendance',
            '85%',
            Icons.people,
            Colors.blue,
          ),
          _buildAnalyticCard(
            'PPE Compliance',
            '92%',
            Icons.health_and_safety,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1C1C1C),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(String dayOfWeek) {
    switch (dayOfWeek.toUpperCase()) {
      case 'MON':
        return 'Monday';
      case 'TUE':
        return 'Tuesday';
      case 'WED':
        return 'Wednesday';
      case 'THU':
        return 'Thursday';
      case 'FRI':
        return 'Friday';
      case 'SAT':
        return 'Saturday';
      case 'SUN':
        return 'Sunday';
      default:
        return dayOfWeek;
    }
  }
}
