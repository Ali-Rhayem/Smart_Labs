import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Static data for analytics
    const totalStudents = 120;
    const totalLabs = 5;
    const avgAttendance = 78.5;
    const avgPPECompliance = 85.2;

    // Monthly attendance data
    final monthlyAttendance = [65.0, 72.0, 78.5, 82.0, 75.0, 88.0];
    final monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1C1C1C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.5,
              children: [
                _buildSummaryCard(
                  'Total Students',
                  totalStudents.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildSummaryCard(
                  'Active Labs',
                  totalLabs.toString(),
                  Icons.science,
                  Colors.green,
                ),
                _buildSummaryCard(
                  'Avg Attendance',
                  '${avgAttendance.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  Colors.orange,
                ),
                _buildSummaryCard(
                  'PPE Compliance',
                  '${avgPPECompliance.toStringAsFixed(1)}%',
                  Icons.health_and_safety,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Attendance Trend Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Trend',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      _buildLineChartData(monthlyAttendance, monthLabels),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Lab Performance List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lab Performance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabPerformanceItem(
                      'Chemistry Lab 101', 92, Colors.green),
                  _buildLabPerformanceItem('Physics Lab 202', 85, Colors.blue),
                  _buildLabPerformanceItem(
                      'Biology Lab 303', 78, Colors.orange),
                  _buildLabPerformanceItem('Computer Lab 404', 73, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Add this
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            // Wrap in Flexible
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis, // Handle text overflow
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabPerformanceItem(
      String labName, int performance, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labName,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: performance / 100,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$performance%',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(List<double> values, List<String> labels) {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < labels.length) {
                return Text(
                  labels[value.toInt()],
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: values.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value);
          }).toList(),
          isCurved: true,
          color: const Color(0xFFFFFF00),
          barWidth: 3,
          dotData: FlDotData(show: false),
        ),
      ],
    );
  }
}
