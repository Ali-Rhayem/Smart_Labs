import 'package:flutter/material.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for student's analytics
    const ppeCompliancePercent = 85; // say 85%
    const totalAttendance = 14; // attended 14 sessions
    const totalSessions = 16; // total sessions conducted
    final attendancePercent = (totalAttendance / totalSessions * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // PPE Commitment Overview
            const Card(
              child: ListTile(
                leading:
                    Icon(Icons.security, size: 40, color: Colors.green),
                title: Text('PPE Commitment'),
                subtitle: Text(
                    'You adhered to PPE rules in $ppeCompliancePercent% of sessions'),
              ),
            ),
            const SizedBox(height: 16),

            // Attendance Overview
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline,
                    size: 40, color: Colors.blue),
                title: const Text('Attendance'),
                subtitle: Text(
                    'You attended $totalAttendance out of $totalSessions sessions '
                    '($attendancePercent%)'),
              ),
            ),
            const SizedBox(height: 16),

            // Additional Dummy Analytics
            Expanded(
              child: Center(
                child: Text(
                  'More analytics coming soon!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
