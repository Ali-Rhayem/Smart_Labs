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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedules',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...schedules.map((schedule) => Card(
              color: const Color(0xFF1C1C1C),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(schedule.dayOfWeek, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${schedule.startTime} - ${schedule.endTime}',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemoveSchedule(schedule),
                ),
              ),
            )),
        ElevatedButton.icon(
          onPressed: onAddSchedule,
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text('Add Schedule'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFFF00),
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
  }
}
