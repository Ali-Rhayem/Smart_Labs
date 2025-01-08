import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/screens/student/lab_details.dart';

class LabCard extends StatelessWidget {
  const LabCard({super.key, required this.lab});
  final Lab lab;

  /// Neon yellow color
  static const Color kNeonAccent = Color(0xFFFFFF00);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            // stops array controls how quickly we transition to black
            stops: [0, 0.03, 1],
            colors: [
              kNeonAccent, // Neon strip
              Color(0xFF1C1C1C), // Transition color
              Color(0xFF1C1C1C), // Card remains dark to the right
            ],
          ),
        ),
        // 3) Clip the same rounded corners so child widgets don't overflow
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          // 4) The main card content goes here
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row of title & icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Lab title and subtitle
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
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => LabDetailScreen(lab: lab),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chevron_right, size: 30),
                      color: kNeonAccent,
                    ),
                  ],
                ),
                // ... add more content below if needed ...
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// If you need a date formatter helper:
String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}
