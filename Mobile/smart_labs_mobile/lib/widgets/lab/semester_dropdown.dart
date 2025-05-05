import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/semester_provider.dart';

class SemesterDropdown extends ConsumerWidget {
  final int selectedSemesterId;
  final Function(int?) onChanged;

  const SemesterDropdown({
    super.key,
    required this.selectedSemesterId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final semestersAsync = ref.watch(semestersProvider);

    return semestersAsync.when(
      loading: () => CircularProgressIndicator(
        color: isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
      ),
      error: (error, stack) => Text(
        'Error: $error',
        style: TextStyle(color: theme.colorScheme.error),
      ),
      data: (semesters) => DropdownButtonFormField<int>(
        value: selectedSemesterId,
        decoration: InputDecoration(
          filled: true,
          fillColor:
              isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white24
                  : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white24
                  : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color:
                  isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
            ),
          ),
        ),
        dropdownColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        style: TextStyle(color: theme.colorScheme.onSurface),
        items: semesters.map((semester) {
          return DropdownMenuItem(
            value: semester.id,
            child: Text(semester.name),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
