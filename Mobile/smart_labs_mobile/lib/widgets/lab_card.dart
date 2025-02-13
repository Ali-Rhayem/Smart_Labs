import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/screens/instructor/instructor_lab_details.dart';
import 'package:smart_labs_mobile/screens/student/student_lab_details.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';

class LabCard extends StatelessWidget {
  const LabCard({
    super.key, 
    required this.lab,
    this.showManageButton = false,
  });

  Future<void> _navigateToDetails(BuildContext context) async {
    final storage = SecureStorage();
    final role = await storage.readRole();

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => role == 'instructor'
            ? InstructorLabDetailScreen(lab: lab)
            : LabDetailScreen(lab: lab),
      ),
    );
  }

  final Lab lab;
  final bool showManageButton;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1C),
          border: Border(
            left: BorderSide(
              color: kNeonAccent,
              width: 5.0,
            ),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            bottomLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
            bottomRight: Radius.circular(11.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
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
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => LabDetailScreen(lab: lab),
                      ),
                    );
                  },
                  color: kNeonAccent,
                  icon: const Icon(Icons.chevron_right, size: 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}
