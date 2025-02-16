import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';

class LabHeader extends StatelessWidget {
  final Lab lab;
  const LabHeader({super.key, required this.lab});

  @override
  Widget build(context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lab.labName,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lab.description,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            Icons.code,
            'Lab Code: ${lab.labCode}',
          ),
          if (lab.semesterId.isNotEmpty && lab.semesterId != '0') ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Semester: ${lab.semesterName}',
            ),
          ],
          if (lab.ppeNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Required PPE',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: lab.ppeNames.map((ppeName) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? const Color(0xFFFFFF00)
                            : theme.colorScheme.primary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFFFFFF00)
                          : theme.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    ppeName.toUpperCase(),
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFFFFF00)
                          : theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Schedule',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...lab.schedule.map((schedule) {
            String dayName = _getDayName(schedule.dayOfWeek);
            // Format time to remove seconds
            String startTime = _formatTime(schedule.startTime);
            String endTime = _formatTime(schedule.endTime);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildInfoRow(
                context,
                Icons.schedule,
                '$dayName: $startTime - $endTime',
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.onSurface,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatTime(String time) {
    // If time contains seconds (HH:mm:ss), remove them
    if (time.split(':').length > 2) {
      return time.substring(0, 5); // Keep only HH:mm
    }
    return time;
  }

  String _getDayName(String dayOfWeek) {
    switch (dayOfWeek.toUpperCase()) {
      case 'MON':
        return 'Monday';
      case 'TUE':
        return 'Tuesday';
      case 'WED':
        return 'Wednesday';
      case 'THU':
        return 'Thursday';
      case 'FRI':
        return 'Friday';
      case 'SAT':
        return 'Saturday';
      case 'SUN':
        return 'Sunday';
      default:
        return dayOfWeek;
    }
  }
}
