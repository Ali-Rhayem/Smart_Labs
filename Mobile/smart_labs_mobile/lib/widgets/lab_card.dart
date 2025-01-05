import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/screens/student/lab_details.dart';

class LabCard extends StatelessWidget {
  const LabCard({super.key, required this.lab});
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C), // Dark grey card background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lab Title & “View” button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Lab Name + Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lab.labName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lab.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              // Neon “View” button to mimic the “Interview” style
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LabDetailScreen(lab: lab),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNeonAccent,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('View'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Additional info (Lab Code, Date, Time)
          Row(
            children: [
              Icon(Icons.code,
                  size: 16, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text(
                'Code: ${lab.labCode}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.calendar_month,
                size: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(lab.date),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time,
                  size: 16, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text(
                '${lab.startTime} - ${lab.endTime}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}
