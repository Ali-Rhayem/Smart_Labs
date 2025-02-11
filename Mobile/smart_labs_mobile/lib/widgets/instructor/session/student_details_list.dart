import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/session_model.dart';
import 'package:smart_labs_mobile/widgets/instructor/session/student_detail_card.dart';

class StudentDetailsList extends StatelessWidget {
  final Session session;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const StudentDetailsList({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                Icons.people_alt_rounded,
                color: kNeonAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Student Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...session.result.map((data) => StudentDetailCard(data: data)),
      ],
    );
  }
}