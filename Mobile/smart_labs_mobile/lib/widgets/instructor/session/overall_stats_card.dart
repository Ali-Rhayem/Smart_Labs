import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/session_model.dart';
import 'package:smart_labs_mobile/widgets/instructor/session/stat_row.dart';

class OverallStatsCard extends StatelessWidget {
  final Session session;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const OverallStatsCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF1C1C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kNeonAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: kNeonAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Overall Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            StatRow(label: 'Total Attendance', value: '${session.totalAttendance}%'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white12),
            ),
            ...session.totalPPECompliance.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StatRow(
                  label: '${entry.key.toUpperCase()} Compliance',
                  value: '${entry.value}%',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}