import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/session_model.dart';

class SessionDetailScreen extends StatelessWidget {
  final Session session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final outputList = session.output; // List<StudentRecord>

    return Scaffold(
      // Same app bar style
      appBar: AppBar(
        title: Text(
          'Session: ${session.id}',
          style:const TextStyle(fontWeight: FontWeight.bold),
        ),
        // backgroundColor: Colors.black,
        backgroundColor: const Color(0xFF121212),
      ),
      // Dark background
      backgroundColor: const Color(0xFF121212),
      // Include bottom nav bar for consistency
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Title
            const Text(
              'Session Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Session Date & Time
            _buildInfoRow(
              icon: Icons.calendar_month,
              label: 'Date',
              value: _formatDate(session.date),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Time',
              value: '${session.startTime} - ${session.endTime}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.library_books,
              label: 'Report',
              value: session.report,
            ),

            const SizedBox(height: 24),

            // Output (Students List)
            const Text(
              'Students',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (outputList.isEmpty)
              Text(
                'No student data available.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: outputList.length,
                itemBuilder: (context, index) {
                  final studentRecord = outputList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Student Info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentRecord.studentName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${studentRecord.studentId}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // Attendance & PPE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Attendance: ${studentRecord.attendance ? 'Yes' : 'No'}',
                              style: TextStyle(
                                color: studentRecord.attendance
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'PPE: ${studentRecord.ppe ? 'Yes' : 'No'}',
                              style: TextStyle(
                                color: studentRecord.ppe
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
