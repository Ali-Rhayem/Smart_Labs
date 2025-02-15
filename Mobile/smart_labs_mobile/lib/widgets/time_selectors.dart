import 'package:flutter/material.dart';

/// A widget for displaying and selecting a start and end [TimeOfDay].
///
/// - [label] is the title text shown above the time pickers (e.g. "Lab Schedule").
/// - [startTime] and [endTime] are the currently selected times.
/// - [onSelectStartTime] and [onSelectEndTime] are called when the user taps
///   the "start time" or "end time" containers, respectively.
class TimeSelectors extends StatelessWidget {
  final String label;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(TimeOfDay) onSelectStartTime;
  final Function(TimeOfDay) onSelectEndTime;

  const TimeSelectors({
    super.key,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.onSelectStartTime,
    required this.onSelectEndTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: isDark
                              ? const ColorScheme.dark(
                                  primary: Color(0xFFFFFF00),
                                  onPrimary: Colors.black,
                                  surface: Color(0xFF1C1C1C),
                                  onSurface: Colors.white,
                                )
                              : theme.colorScheme,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    onSelectStartTime(picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1C1C1C)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.white24
                          : theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Time',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        startTime.format(context),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: isDark
                              ? const ColorScheme.dark(
                                  primary: Color(0xFFFFFF00),
                                  onPrimary: Colors.black,
                                  surface: Color(0xFF1C1C1C),
                                  onSurface: Colors.white,
                                )
                              : theme.colorScheme,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    onSelectEndTime(picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1C1C1C)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.white24
                          : theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Time',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        endTime.format(context),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
