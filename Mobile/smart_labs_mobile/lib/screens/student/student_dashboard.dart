import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/dashboard_analytics_model.dart';
import 'package:smart_labs_mobile/providers/dashboard_analytics_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final analyticsAsync = ref.watch(dashboardAnalyticsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: isDark ? const Color(0xFF1C1C1C) : null,
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error',
              style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (analytics) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.3,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final items = [
                    (
                      'Total Labs',
                      analytics.totalLabs.toString(),
                      Icons.science,
                      Colors.blue
                    ),
                    (
                      'Avg Attendance',
                      '${analytics.avgAttendance.toStringAsFixed(1)}%',
                      Icons.people,
                      Colors.green
                    ),
                    (
                      'PPE Compliance',
                      '${analytics.ppeCompliance.toStringAsFixed(1)}%',
                      Icons.health_and_safety,
                      Colors.orange
                    ),
                    (
                      'Total Students',
                      analytics.totalStudents.toString(),
                      Icons.school,
                      Colors.purple
                    ),
                  ];
                  final item = items[index];
                  return _buildSummaryCard(
                    item.$1,
                    item.$2,
                    item.$3,
                    item.$4,
                    isDark,
                    theme,
                  );
                },
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: analytics.labs
                    .where(
                        (lab) => lab.labId.isNotEmpty && lab.labName.isNotEmpty)
                    .length,
                itemBuilder: (context, index) {
                  final validLabs = analytics.labs
                      .where((lab) =>
                          lab.labId.isNotEmpty && lab.labName.isNotEmpty)
                      .toList();
                  return _buildLabCard(validLabs[index], isDark, theme);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon,
      Color color, bool isDark, ThemeData theme) {
    return Card(
      elevation: isDark ? 0 : 1,
      color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabCard(
      LabDashboardAnalytics lab, bool isDark, ThemeData theme) {
    if (lab.labId.isEmpty || lab.labName.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: isDark ? 0 : 1,
      color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
        ),
        collapsedShape: const RoundedRectangleBorder(
          side: BorderSide.none,
        ),
        title: Text(
          lab.labName,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildProgressStat(
                          'Attendance',
                          lab.totalAttendance,
                          Icons.people,
                          Colors.blue,
                          isDark,
                          theme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildProgressStat(
                          'PPE Compliance',
                          lab.totalPPECompliance,
                          Icons.health_and_safety,
                          Colors.green,
                          isDark,
                          theme,
                        ),
                      ),
                    ],
                  ),
                  if (lab.xaxis.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 8),
                        child: LineChart(_buildLineChartData(
                          lab.totalAttendanceByTime,
                          lab.xaxis,
                          isDark,
                          theme,
                        )),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String title, int value, IconData icon, Color color,
      bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          '$value%',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(
      List<int> values, List<String> labels, bool isDark, ThemeData theme) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < labels.length) {
                final date = labels[value.toInt()];
                // Format the date to show only month and day
                final parts = date.split('/');
                if (parts.length >= 2) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '${parts[0]}/${parts[1]}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  );
                }
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: (values.length - 1).toDouble(),
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: values.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.toDouble());
          }).toList(),
          isCurved: true,
          color: isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: isDark
                    ? const Color(0xFFFFFF00)
                    : theme.colorScheme.primary,
                strokeWidth: 2,
                strokeColor: isDark ? Colors.black : Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color:
                (isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary)
                    .withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
