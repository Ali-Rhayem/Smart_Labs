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

  final Lab lab;
  final bool showManageButton;

  // Remove the hardcoded neon color if you want the accent to change with theme
  // Otherwise, keep it if you specifically always want neon accent in both themes
  static const Color kNeonAccent = Color(0xFFFFFF00);

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

  @override
  Widget build(BuildContext context) {
    // Grab the active theme & color scheme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),

        // Instead of hardcoded color, use the theme's cardColor
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            left: BorderSide(
              // If you prefer the neon accent always, keep kNeonAccent
              // If you want dynamic color, use colorScheme.primary or secondary
              color: colorScheme.primary,
              width: 5.0,
            ),
          ),
          borderRadius: const BorderRadius.only(
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
                // This expanded part shows the name & description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lab.labName,
                        // Use theme's text style, or copyWith to override
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lab.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // The arrow icon
                IconButton(
                  onPressed: () => _navigateToDetails(context),
                  color: colorScheme.primary,
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
