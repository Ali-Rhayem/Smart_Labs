import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:smart_labs_mobile/models/lab_schedule.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/utils/date_time_utils.dart';
import 'package:smart_labs_mobile/widgets/lab_schedules_list.dart';
import 'package:smart_labs_mobile/widgets/lab_student_input.dart';
import 'package:smart_labs_mobile/widgets/ppe_dropdwon.dart';
import 'package:smart_labs_mobile/widgets/time_selectors.dart';
import 'package:smart_labs_mobile/widgets/week_day_selector.dart';
import 'package:smart_labs_mobile/providers/room_provider.dart';
import 'package:smart_labs_mobile/providers/semester_provider.dart';

var logger = Logger();
// TODO: add error display message

class CreateLabScreen extends ConsumerStatefulWidget {
  const CreateLabScreen({super.key});

  @override
  ConsumerState<CreateLabScreen> createState() => _CreateLabScreenState();
}

class _CreateLabScreenState extends ConsumerState<CreateLabScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labNameController;
  late TextEditingController _labCodeController;
  late TextEditingController _descriptionController;
  late TextEditingController _studentInputController;
  late TextEditingController _roomController;
  late TextEditingController _semesterController;
  final List<LabSchedule> _schedules = [];

  int _selectedWeekday = DateTime.now().weekday;
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  final ApiService _apiService = ApiService();

  final List<String> _selectedPPE = [];
  final List<String> _selectedStudents = [];
  final List<String> _selectedPPEIds = [];
  int _selectedSemesterId = 0;

  @override
  void initState() {
    super.initState();
    _labNameController = TextEditingController();
    _labCodeController = TextEditingController();
    _descriptionController = TextEditingController();
    _studentInputController = TextEditingController();
    _roomController = TextEditingController();
    _semesterController = TextEditingController();
  }

  @override
  void dispose() {
    _labNameController.dispose();
    _labCodeController.dispose();
    _descriptionController.dispose();
    _studentInputController.dispose();
    _roomController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Create New Lab'),
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lab Name',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _labNameController,
                label: 'Name',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter lab name' : null,
              ),
              const SizedBox(height: 16),
              Text(
                'Lab Code',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _labCodeController,
                label: 'Code',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter lab code' : null,
              ),
              const SizedBox(height: 16),
              Text(
                'Lab Description',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              const SizedBox(height: 16),
              PPEDropdown(
                selectedPPEIds: _selectedPPEIds,
                onAddPPE: (ppeId, ppeName) {
                  setState(() {
                    _selectedPPEIds.add(ppeId);
                    _selectedPPE.add(ppeName);
                  });
                },
                onRemovePPE: (ppeId, ppeName) {
                  setState(() {
                    _selectedPPEIds.remove(ppeId);
                    _selectedPPE.remove(ppeName);
                  });
                },
              ),
              const SizedBox(height: 16),
              WeekdaySelector(
                selectedWeekday:
                    _selectedWeekday, // The current day from your State
                onWeekdayChanged: (newDay) {
                  setState(() {
                    _selectedWeekday = newDay;
                  });
                },
              ),
              const SizedBox(height: 16),
              TimeSelectors(
                label: 'Lab Schedule',
                startTime: _startTime,
                endTime: _endTime,
                onSelectStartTime: () => _selectTime(true),
                onSelectEndTime: () => _selectTime(false),
              ),
              const SizedBox(height: 16),
              LabSchedulesList(
                schedules: _schedules,
                onAddSchedule: _addSchedule, // calls the parent's method
                onRemoveSchedule: (schedule) {
                  setState(() {
                    _schedules.remove(schedule);
                  });
                },
              ),
              const SizedBox(height: 16),
              LabStudentInput(
                students: _selectedStudents,
                onAddStudent: (newStudent) {
                  setState(() => _selectedStudents.add(newStudent));
                },
                onRemoveStudent: (studentToRemove) {
                  setState(() => _selectedStudents.remove(studentToRemove));
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Room',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildRoomDropdown(),
              const SizedBox(height: 16),
              const Text(
                'Semester',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildSemesterDropdown(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFFFFFF00)
                        : theme.colorScheme.primary,
                    foregroundColor:
                        isDark ? Colors.black : theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Create Lab',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.black : theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
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
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _addSchedule() {
    setState(() {
      _schedules.add(
        LabSchedule(
          dayOfWeek: getWeekdayName(_selectedWeekday),
          startTime: formatTimeToHHMM(_startTime),
          endTime: formatTimeToHHMM(_endTime),
        ),
      );
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPPE.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select required PPE')),
        );
        return;
      }
      if (_selectedStudents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one student')),
        );
        return;
      }
      if (_schedules.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one schedule')),
        );
        return;
      }

      final labData = {
        "lab": {
          "labCode": _labCodeController.text,
          "labName": _labNameController.text,
          "schedule": _schedules.map((s) => s.toJson()).toList(),
          "description": _descriptionController.text,
          "endLab": false,
          "room": _roomController.text,
          "PPE": _selectedPPEIds,
          "semesterId": _selectedSemesterId,
        },
        "student_Emails": _selectedStudents
      };

      try {
        final response = await _apiService.post('/Lab', labData);
        if (response['success']) {
          if (mounted) {
            await ref.read(labsProvider.notifier).fetchLabs();
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(response['message'] ?? 'Failed to create lab')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create lab: $e')),
          );
        }
      }
    }
  }

  Widget _buildRoomDropdown() {
    return Consumer(
      builder: (context, ref, child) {
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
            value: _roomController.text.isEmpty ? null : _roomController.text,
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
                  color: isDark
                      ? const Color(0xFFFFFF00)
                      : theme.colorScheme.primary,
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
            items: [
              ...rooms.map((room) {
                return DropdownMenuItem(
                  value: room.name,
                  child: Text(room.name),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _roomController.text = value ?? '';
              });
            },
            validator: (value) => value == null ? 'Please select a room' : null,
          ),
        );
      },
    );
  }

  Widget _buildSemesterDropdown() {
    return Consumer(
      builder: (context, ref, child) {
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
            value: _selectedSemesterId,
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
                  color: isDark
                      ? const Color(0xFFFFFF00)
                      : theme.colorScheme.primary,
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
            onChanged: (value) {
              setState(() {
                _selectedSemesterId = value ?? 0;
              });
            },
          ),
        );
      },
    );
  }
}
