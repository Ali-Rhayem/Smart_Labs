import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_analytics_model.dart';
import 'package:smart_labs_mobile/providers/lab_analytics_provider.dart';

class StudentAnalyticsTab extends ConsumerWidget {
  final String labId;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const StudentAnalyticsTab({super.key, required this.labId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final analyticsAsync = ref.watch(labAnalyticsProvider(labId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(labAnalyticsProvider(labId));
      },
      color: isDark ? kNeonAccent : theme.colorScheme.primary,
      child: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error',
              style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (analytics) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallStats(analytics, isDark, theme),
              const SizedBox(height: 24),
              _buildPPEComplianceSection(analytics, isDark, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStats(LabAnalytics analytics, bool isDark, ThemeData theme) {
    return Card(
      color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      elevation: isDark ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Statistics',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatTile(
              'Total Attendance',
              '${analytics.totalAttendance}%',
              Icons.people,
              _getPercentageColor(analytics.totalAttendance),
              isDark,
              theme,
            ),
            const SizedBox(height: 12),
            _buildStatTile(
              'Overall PPE Compliance',
              '${analytics.totalPPECompliance}%',
              Icons.health_and_safety,
              _getPercentageColor(analytics.totalPPECompliance),
              isDark,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPPEComplianceSection(
      LabAnalytics analytics, bool isDark, ThemeData theme) {
    return Card(
      color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      elevation: isDark ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PPE Compliance Breakdown',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...analytics.ppeCompliance.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildProgressBar(
                  entry.key.toUpperCase(),
                  entry.value.toDouble(),
                  isDark,
                  theme,
                  _getPercentageColor(entry.value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color color,
      bool isDark, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double value, bool isDark,
      ThemeData theme, Color percentageColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                color: percentageColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation(percentageColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Color _getPercentageColor(num percentage) {
    if (percentage >= 90) {
      return Colors.green[400]!;
    } else if (percentage >= 70) {
      return Colors.yellow[600]!;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red[400]!;
    }
  }
}