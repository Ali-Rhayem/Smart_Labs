import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_analytics_model.dart';
import 'package:smart_labs_mobile/providers/lab_analytics_provider.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';

class StudentAnalyticsTab extends ConsumerWidget {
  final String labId;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const StudentAnalyticsTab({super.key, required this.labId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final analyticsAsync = ref.watch(labAnalyticsProvider(labId));
    final storage = SecureStorage();

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
        data: (analytics) => FutureBuilder<String?>(
          future: storage.readId(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final studentId = snapshot.data!;
            final studentAnalytics = analytics.people.firstWhere(
              (student) => student.id.toString() == studentId,
              orElse: () => throw Exception('Student data not found'),
            );

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMyStats(studentAnalytics, isDark, theme),
                  const SizedBox(height: 24),
                  _buildPPEComplianceSection(studentAnalytics, isDark, theme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMyStats(
      StudentAnalytics analytics, bool isDark, ThemeData theme) {
    return Card(
      color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Performance',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatTile(
              'Attendance',
              '${analytics.attendancePercentage}%',
              Icons.people,
              isDark ? kNeonAccent : theme.colorScheme.primary,
              isDark,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPPEComplianceSection(
      StudentAnalytics analytics, bool isDark, ThemeData theme) {
    return Card(
      color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My PPE Compliance',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets from analytics_tab.dart
  Widget _buildStatTile(String title, String value, IconData icon, Color color,
          bool isDark, ThemeData theme) =>
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildProgressBar(
          String label, double value, bool isDark, ThemeData theme) =>
      Column(
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
                  color: isDark ? kNeonAccent : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(
                isDark ? kNeonAccent : theme.colorScheme.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
}
