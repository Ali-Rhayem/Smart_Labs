import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:smart_labs_mobile/controllers/create_lab_controller.dart';
import 'package:smart_labs_mobile/models/lab_schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/widgets/lab/custom_text_field.dart';
import 'package:smart_labs_mobile/widgets/lab/room_dropdown.dart';
import 'package:smart_labs_mobile/widgets/lab/semester_dropdown.dart';
import 'package:smart_labs_mobile/widgets/lab_schedules_list.dart';
import 'package:smart_labs_mobile/widgets/lab_student_input.dart';
import 'package:smart_labs_mobile/widgets/ppe_dropdwon.dart';
import 'package:smart_labs_mobile/widgets/week_day_selector.dart';

import '../../widgets/time_selectors.dart';

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
  final _controller = CreateLabController();

  int _selectedWeekday = DateTime.now().weekday;
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

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
              CustomTextField(
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
              CustomTextField(
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
              CustomTextField(
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
                onSelectStartTime: (picked) {
                  setState(() {
                    _startTime = picked;
                  });
                },
                onSelectEndTime: (picked) {
                  setState(() {
                    _endTime = picked;
                  });
                },
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
              RoomDropdown(
                controller: _roomController,
                onChanged: (value) {
                  setState(() {
                    _roomController.text = value ?? '';
                  });
                },
              ),
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
              SemesterDropdown(
                selectedSemesterId: _selectedSemesterId,
                onChanged: (value) {
                  setState(() {
                    _selectedSemesterId = value ?? 0;
                  });
                },
              ),
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

  void _addSchedule() {
    _controller.addSchedule(
      selectedWeekday: _selectedWeekday,
      startTime: _startTime,
      endTime: _endTime,
      onScheduleAdded: (schedule) {
        setState(() {
          _schedules.add(schedule);
        });
      },
    );
  }

  Future<void> _submitForm() async {
    await _controller.handleSubmission(
      ref: ref,
      context: context,
      formKey: _formKey,
      selectedPPE: _selectedPPE,
      selectedStudents: _selectedStudents,
      schedules: _schedules,
      labCode: _labCodeController.text,
      labName: _labNameController.text,
      description: _descriptionController.text,
      room: _roomController.text,
      selectedPPEIds: _selectedPPEIds,
      selectedSemesterId: _selectedSemesterId,
    );
  }
}
