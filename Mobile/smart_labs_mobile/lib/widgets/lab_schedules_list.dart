import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/lab_schedule.dart';

class LabSchedulesList extends StatelessWidget {
  final List<LabSchedule> schedules;
  final VoidCallback onAddSchedule;
  final Function(LabSchedule) onRemoveSchedule;

  const LabSchedulesList({
    super.key,
    required this.schedules,
    required this.onAddSchedule,
    required this.onRemoveSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedules',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...schedules.map((schedule) => Card(
              color: theme.colorScheme.surface,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  schedule.dayOfWeek,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                subtitle: Text(
                  '${schedule.startTime} - ${schedule.endTime}',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemoveSchedule(schedule),
                ),
              ),
            )),
        ElevatedButton.icon(
          onPressed: onAddSchedule,
          icon: const Icon(Icons.add),
          label: const Text('Add Schedule'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}
