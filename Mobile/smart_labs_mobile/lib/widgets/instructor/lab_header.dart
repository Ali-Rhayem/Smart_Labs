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
          Row(
            children: [
              Icon(Icons.code, color: theme.colorScheme.onSurface, size: 18),
              const SizedBox(width: 8),
              Text(
                'Lab Code: ${lab.labCode}',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: theme.colorScheme.onSurface, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$dayName:',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${schedule.startTime} - ${schedule.endTime}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          })
        ],
      ),
    );
  }
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
