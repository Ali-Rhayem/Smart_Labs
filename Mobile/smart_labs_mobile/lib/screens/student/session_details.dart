import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/session_model.dart';

class SessionDetailScreen extends StatelessWidget {
  final Session session;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Session Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF121212),
      ),
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallStats(),
            const SizedBox(height: 24),
            _buildStudentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats() {
    return Card(
      color: const Color(0xFF1C1C1C),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Statistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Attendance', '${session.totalAttendance}%'),
            const SizedBox(height: 8),
            ...session.totalPPECompliance.entries.map(
              (entry) => _buildStatRow(
                '${entry.key.toUpperCase()} Compliance',
                '${entry.value}%',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Student Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...session.result.entries.map((entry) {
          final studentId = entry.key;
          final data = entry.value;
          return Card(
            color: const Color(0xFF1C1C1C),
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(
                data.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Attendance: ${data.attendancePercentage}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ...data.ppeCompliance.entries.map(
                        (ppe) => _buildStatRow(
                          '${ppe.key.toUpperCase()} Compliance',
                          '${ppe.value}%',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
