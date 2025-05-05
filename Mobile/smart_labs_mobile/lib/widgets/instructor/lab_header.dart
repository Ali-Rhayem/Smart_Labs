import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';

class LabHeader extends StatefulWidget {
  final Lab lab;
  final bool disableToggle;

  const LabHeader({
    super.key,
    required this.lab,
    this.disableToggle = false,
  });

  @override
  State<LabHeader> createState() => _LabHeaderState();
}

class _LabHeaderState extends State<LabHeader> {
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    // Listen to keyboard visibility changes
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          _isExpanded = !visible; // Collapse when keyboard is visible
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Always visible header content
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.lab.labName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: widget.disableToggle
                    ? null
                    : () => setState(() => _isExpanded = !_isExpanded),
              ),
            ],
          ),

          // Expandable content
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            Text(
              widget.lab.description,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.code,
              'Lab Code: ${widget.lab.labCode}',
            ),
            if (widget.lab.semesterId.isNotEmpty &&
                widget.lab.semesterId != '0') ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.calendar_today,
                'Semester: ${widget.lab.semesterName}',
              ),
            ],
            if (widget.lab.ppeNames.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Required PPE',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.lab.ppeNames.map((ppeName) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? const Color(0xFFFFFF00)
                              : theme.colorScheme.primary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFFFFFF00)
                            : theme.colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      ppeName.toUpperCase(),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFFFFF00)
                            : theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Schedule',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.lab.schedule.map((schedule) {
              String dayName = _getDayName(schedule.dayOfWeek);
              String startTime = _formatTime(schedule.startTime);
              String endTime = _formatTime(schedule.endTime);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildInfoRow(
                  context,
                  Icons.schedule,
                  '$dayName: $startTime - $endTime',
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.onSurface,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatTime(String time) {
    if (time.split(':').length > 2) {
      return time.substring(0, 5);
    }
    return time;
  }

  String _getDayName(String dayOfWeek) {
    switch (dayOfWeek.toUpperCase()) {
      case 'MON':
        return 'Monday';
      case 'TUE':
        return 'Tuesday';
      case 'WED':
        return 'Wednesday';
      case 'THU':
        return 'Thursday';
      case 'FRI':
        return 'Friday';
      case 'SAT':
        return 'Saturday';
      case 'SUN':
        return 'Sunday';
      default:
        return dayOfWeek;
    }
  }
}
