import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/session_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
            _buildOverallStats(),
            const SizedBox(height: 32),
            _buildStudentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
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
                      theme.colorScheme.surface.withValues(alpha: 0.9)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
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
                        color:
                            (isDark ? kNeonAccent : theme.colorScheme.primary)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        color: isDark ? kNeonAccent : theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Overall Statistics',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildStatRow(
                    'Total Attendance', '${session.totalAttendance}%'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: theme.dividerColor),
                ),
                ...session.totalPPECompliance.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildStatRow(
                      '${entry.key.toUpperCase()} Compliance',
                      '${entry.value}%',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentsList() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? kNeonAccent : theme.colorScheme.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.people_alt_rounded,
                    color: isDark ? kNeonAccent : theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Student Details',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...session.result.map((data) {
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
                                theme.colorScheme.surface.withValues(alpha: 0.9)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            (isDark ? kNeonAccent : theme.colorScheme.primary)
                                .withValues(alpha: 0),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
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
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: data.user.imageUrl != null &&
                              data.user.imageUrl!.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                '${dotenv.env['IMAGE_BASE_URL']}/${data.user.imageUrl}',
                              ),
                              backgroundColor: isDark
                                  ? kNeonAccent
                                  : theme.colorScheme.primary,
                              onBackgroundImageError: (_, __) {
                                // If image fails to load, it will show the fallback initial
                                return;
                              },
                              child: Text(
                                data.user.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: isDark
                                  ? kNeonAccent
                                  : theme.colorScheme.primary,
                              child: Text(
                                data.user.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Divider(color: theme.dividerColor),
                              const SizedBox(height: 12),
                              ...data.ppeCompliance.entries.map(
                                (ppe) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildStatRow(
                                    '${ppe.key.toUpperCase()} Compliance',
                                    '${ppe.value}%',
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
            }),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        // Extract percentage value and convert to double
        final percentage = double.tryParse(value.replaceAll('%', '')) ?? 0.0;

        // Calculate color based on percentage
        Color percentageColor;
        if (percentage >= 90) {
          percentageColor = Colors.green[400]!;
        } else if (percentage >= 70) {
          percentageColor = Colors.yellow[600]!;
        } else if (percentage >= 50) {
          percentageColor = Colors.orange;
        } else {
          percentageColor = Colors.red[400]!;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: percentageColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: percentageColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: percentageColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    percentage >= 90
                        ? Icons.check_circle
                        : percentage >= 70
                            ? Icons.info
                            : percentage >= 50
                                ? Icons.warning
                                : Icons.error,
                    size: 16,
                    color: percentageColor,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
