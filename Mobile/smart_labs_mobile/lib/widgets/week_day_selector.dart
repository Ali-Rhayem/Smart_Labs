import 'package:flutter/material.dart';

/// A widget that displays a horizontal list of weekdays (Mon-Sun).
/// 
/// [selectedWeekday] should be a value from 1 (Monday) to 7 (Sunday).
/// [onWeekdayChanged] is called when the user taps a weekday.
class WeekdaySelector extends StatelessWidget {
  final int selectedWeekday;
  final ValueChanged<int> onWeekdayChanged;

  const WeekdaySelector({
    super.key,
    required this.selectedWeekday,
    required this.onWeekdayChanged,
  });

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Day of Week',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weekdays.length,
            itemBuilder: (context, index) {
              final dayIndex = index + 1; // 1 = Monday, 7 = Sunday
              final isSelected = selectedWeekday == dayIndex;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => onWeekdayChanged(dayIndex),
                  child: Container(
                    width: 45,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFFFFFF00) 
                          : const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Center(
                      child: Text(
                        weekdays[index],
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.black 
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
