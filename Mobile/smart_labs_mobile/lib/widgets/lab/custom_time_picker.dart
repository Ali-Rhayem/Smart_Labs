import 'package:flutter/material.dart';

class CustomTimePicker extends StatelessWidget {
  final bool isStartTime;
  final TimeOfDay currentTime;
  final Function(TimeOfDay) onTimeSelected;

  const CustomTimePicker({
    super.key,
    required this.isStartTime,
    required this.currentTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextButton(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: currentTime,
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
                    : ColorScheme.light(
                        primary: theme.colorScheme.primary,
                        onPrimary: theme.colorScheme.onPrimary,
                        surface: theme.colorScheme.surface,
                        onSurface: theme.colorScheme.onSurface,
                      ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onTimeSelected(picked);
        }
      },
      child: Text(
        '${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')}',
        style: TextStyle(
          color: isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
        ),
      ),
    );
  }
}
