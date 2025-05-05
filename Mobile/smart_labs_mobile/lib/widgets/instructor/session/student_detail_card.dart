import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_labs_mobile/models/session_model.dart';
import 'package:smart_labs_mobile/widgets/instructor/session/stat_row.dart';

class StudentDetailCard extends StatelessWidget {
  final StudentSessionData data;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const StudentDetailCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF2C2C2C), Color(0xFF1C1C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withOpacity(0.9)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? kNeonAccent : theme.colorScheme.primary)
                  .withOpacity(0),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            onExpansionChanged: (expanded) {
              setState(() {});
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: _buildAvatar(context),
            title: Text(
              data.user.name,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Attendance: ${data.attendancePercentage}%',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Divider(
                        color: theme.colorScheme.onSurface.withOpacity(0.1)),
                    const SizedBox(height: 12),
                    ...data.ppeCompliance.entries.map(
                      (ppe) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StatRow(
                          label: '${ppe.key.toUpperCase()} Compliance',
                          value: '${ppe.value}%',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return data.user.imageUrl != null && data.user.imageUrl!.isNotEmpty
        ? CircleAvatar(
            backgroundImage: NetworkImage(
              '${dotenv.env['IMAGE_BASE_URL']}/${data.user.imageUrl}',
            ),
            backgroundColor: isDark ? kNeonAccent : theme.colorScheme.primary,
            onBackgroundImageError: (_, __) {
              // If image fails to load, it will show the fallback initial
              return;
            },
            child: Text(
              data.user.name.split(' ')[0][0].toUpperCase(),
              style: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : CircleAvatar(
            backgroundColor: isDark ? kNeonAccent : theme.colorScheme.primary,
            child: Text(
              data.user.name.split(' ')[0][0].toUpperCase(),
              style: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
  }
}
