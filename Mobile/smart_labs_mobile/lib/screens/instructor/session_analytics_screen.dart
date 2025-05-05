import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_labs_mobile/models/session_model.dart';

class SessionAnalyticsScreen extends StatelessWidget {
  final Session session;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const SessionAnalyticsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Session Analytics',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallMetrics(context),
            const SizedBox(height: 24),
            _buildPPEComplianceChart(context),
            const SizedBox(height: 24),
            _buildPPEComplianceTrends(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallMetrics(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildMetricCard(
          context,
          'Total Attendance',
          session.totalAttendance.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildMetricCard(
          context,
          'Avg PPE Compliance',
          _calculateAveragePPE(session.totalPPECompliance).round().toString(),
          Icons.health_and_safety,
          Colors.green,
        ),
        _buildMetricCard(
          context,
          'Total Students',
          session.result.length.toString(),
          Icons.school,
          Colors.orange,
        ),
        _buildMetricCard(
          context,
          'PPE Categories',
          session.totalPPECompliance.length.toString(),
          Icons.category,
          Colors.purple,
        ),
      ],
    );
  }

  double _calculateAveragePPE(Map<String, num> ppeCompliance) {
    if (ppeCompliance.isEmpty) return 0;
    return ppeCompliance.values.reduce((a, b) => a + b) / ppeCompliance.length;
  }

  Widget _buildMetricCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            title.contains('Total Students') || title.contains('PPE Categories')
                ? value
                : '$value%',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPPEComplianceChart(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 350,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PPE Compliance Distribution',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return PieChart(
                  PieChartData(
                    sections: _generatePPESections(context),
                    sectionsSpace: 2,
                    centerSpaceRadius: constraints.maxHeight * 0.15,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend(context),
        ],
      ),
    );
  }

  Widget _buildChartLegend(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [Colors.blue, Colors.green, Colors.orange];
    final entries = session.totalPPECompliance.entries.toList();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: entries.asMap().entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[entry.key],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              entry.value.key.toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<PieChartSectionData> _generatePPESections(BuildContext context) {
    final colors = [Colors.blue, Colors.green, Colors.orange];
    final entries = session.totalPPECompliance.entries.toList();

    return List.generate(entries.length, (i) {
      final entry = entries[i];
      return PieChartSectionData(
        color: colors[i],
        value: entry.value.toDouble(),
        title: '${entry.value}%',
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    });
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

  Widget _buildPPEComplianceTrends(BuildContext context) {
    if (session.ppeComplianceByTime.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PPE Compliance Trends',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
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
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: _generateLineBarsData(),
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...session.ppeComplianceByTime.keys.toList().asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: [
                                Colors.blue,
                                Colors.green,
                                Colors.orange
                              ][entry.key],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.value.toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  List<LineChartBarData> _generateLineBarsData() {
    final colors = [Colors.blue, Colors.green, Colors.orange];
    final entries = session.ppeComplianceByTime.entries.toList();

    return List.generate(entries.length, (i) {
      final entry = entries[i];
      return LineChartBarData(
        spots: entry.value
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
            .toList(),
        color: colors[i],
        barWidth: 3,
        dotData: FlDotData(show: true),
        isCurved: true,
        belowBarData: BarAreaData(
          show: true,
          color: colors[i].withOpacity(0.1),
        ),
      );
    });
  }
}
