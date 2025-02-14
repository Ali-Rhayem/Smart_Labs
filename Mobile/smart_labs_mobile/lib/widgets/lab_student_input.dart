import 'package:flutter/material.dart';

class LabStudentInput extends StatefulWidget {
  final List<String> students;

  final ValueChanged<String> onAddStudent;

  final ValueChanged<String> onRemoveStudent;

  const LabStudentInput({
    super.key,
    required this.students,
    required this.onAddStudent,
    required this.onRemoveStudent,
  });

  @override
  LabStudentInputState createState() => LabStudentInputState();
}

class LabStudentInputState extends State<LabStudentInput> {
  // Local controller for the "Enter student ID" TextField
  final TextEditingController _controller = TextEditingController();

  /// Handle add button press
  void _handleAdd() {
    if (_controller.text.isNotEmpty) {
      widget.onAddStudent(_controller.text);
      _controller.clear();
    }
  }

  /// Build the entire widget UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Students',
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
              child: TextFormField(
                controller: _controller,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Enter student ID',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1C1C1C)
                      : theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFFFFFF00)
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _handleAdd,
              icon: Icon(
                Icons.add,
                color: isDark
                    ? const Color(0xFFFFFF00)
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.students.map((student) {
            return Chip(
              label: Text(
                student,
                style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
              backgroundColor:
                  isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
              side: BorderSide(
                color: isDark ? Colors.black : Colors.transparent,
              ),
              deleteIcon: Icon(
                Icons.close,
                size: 18,
                color: isDark ? Colors.black : Colors.white,
              ),
              onDeleted: () => widget.onRemoveStudent(student),
            );
          }).toList(),
        ),
      ],
    );
  }
}
