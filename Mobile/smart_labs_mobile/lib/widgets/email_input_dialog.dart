import 'package:flutter/material.dart';

class EmailInputDialog extends StatefulWidget {
  final String title;
  final Function(List<String>) onSubmit;

  const EmailInputDialog({
    super.key,
    required this.title,
    required this.onSubmit,
  });

  @override
  State<EmailInputDialog> createState() => _EmailInputDialogState();
}

class _EmailInputDialogState extends State<EmailInputDialog> {
  final List<String> _emails = [];
  final TextEditingController _controller = TextEditingController();

  void _addEmail(String email) {
    if (email.isNotEmpty) {
      setState(() {
        _emails.add(email);
      });
      _controller.clear();
    }
  }

  void _removeEmail(String email) {
    setState(() {
      _emails.remove(email);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor:
          isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Email Addresses',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _emails
                        .map((email) => Chip(
                              label: Text(email),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeEmail(email),
                              backgroundColor:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                            ))
                        .toList(),
                  ),
                  TextField(
                    controller: _controller,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Enter student email addresses',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onSubmitted: _addEmail,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    widget.onSubmit(_emails);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFFFFFF00)
                        : theme.colorScheme.primary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                  ),
                  child: const Text('ADD'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
