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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Students',
          style: TextStyle(
            color: Colors.white,
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter student ID',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1C1C1C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFFFF00)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _handleAdd,
              icon: const Icon(Icons.add, color: Color(0xFFFFFF00)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.students.map((student) {
            return Chip(
              label: Text(student, style: const TextStyle(color: Colors.black)),
              backgroundColor: const Color(0xFFFFFF00),
              side: const BorderSide(color: Colors.black),
              labelStyle: const TextStyle(color: Colors.black),
              deleteIcon: const Icon(Icons.close, size: 18, color: Colors.black),
              onDeleted: () => widget.onRemoveStudent(student),
            );
          }).toList(),
        ),
      ],
    );
  }
}
