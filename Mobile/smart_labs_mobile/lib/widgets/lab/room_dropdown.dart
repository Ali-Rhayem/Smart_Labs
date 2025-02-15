import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/room_provider.dart';

class RoomDropdown extends ConsumerWidget {
  final TextEditingController controller;
  final Function(String?) onChanged;

  const RoomDropdown({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final roomsAsync = ref.watch(roomsProvider);

    return roomsAsync.when(
      loading: () => CircularProgressIndicator(
        color: isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
      ),
      error: (error, stack) => Text(
        'Error: $error',
        style: TextStyle(color: theme.colorScheme.error),
      ),
      data: (rooms) => DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        decoration: InputDecoration(
          filled: true,
          fillColor:
              isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white24
                  : theme.colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white24
                  : theme.colorScheme.onSurface.withOpacity(0.2),
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
        hint: Text(
          'Select Room',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        items: rooms.map((room) {
          return DropdownMenuItem(
            value: room.name,
            child: Text(room.name),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select a room' : null,
      ),
    );
  }
}
