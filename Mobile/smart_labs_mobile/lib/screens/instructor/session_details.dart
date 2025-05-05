import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/session_model.dart';
import 'package:smart_labs_mobile/widgets/instructor/session/overall_stats_card.dart';
import 'package:smart_labs_mobile/widgets/instructor/session/student_details_list.dart';

class SessionDetailScreen extends StatelessWidget {
  final Session session;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Session Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : theme.colorScheme.surface,
      ),
      backgroundColor:
          isDark ? const Color(0xFF121212) : theme.colorScheme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OverallStatsCard(session: session),
            const SizedBox(height: 32),
            StudentDetailsList(session: session),
          ],
        ),
      ),
    );
  }
}
