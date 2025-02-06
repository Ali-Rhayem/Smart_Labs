import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/utils/date_time_utils.dart';
import 'package:smart_labs_mobile/widgets/lab_schedules_list.dart';
import 'package:smart_labs_mobile/widgets/lab_student_input.dart';
import 'package:smart_labs_mobile/widgets/lab_text_field.dart';
import 'package:smart_labs_mobile/widgets/ppe_dropdwon.dart';
import 'package:smart_labs_mobile/widgets/time_selectors.dart';
import 'package:smart_labs_mobile/widgets/week_day_selector.dart';

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
  final List<LabSchedule> _schedules = [];

  int _selectedWeekday = DateTime.now().weekday;
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  final ApiService _apiService = ApiService();

  final List<String> _selectedPPE = [];
  final List<String> _selectedStudents = [];
  final List<String> _selectedPPEIds = [];

  @override
  void initState() {
    super.initState();
    _labNameController = TextEditingController();
    _labCodeController = TextEditingController();
    _descriptionController = TextEditingController();
    _studentInputController = TextEditingController();
    _roomController = TextEditingController();
  }

  @override
  void dispose() {
    _labNameController.dispose();
    _labCodeController.dispose();
    _descriptionController.dispose();
    _studentInputController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Create New Lab'),
        backgroundColor: const Color(0xFF1C1C1C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lab Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              LabTextField(
                controller: _labNameController,
                label: 'Name',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter lab name' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Lab Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              LabTextField(
                controller: _labCodeController,
                label: 'Code',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter lab code' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Lab Description',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              LabTextField(
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
              LabTextField(
                controller: _roomController,
                label: 'Room',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter room number' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFF00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create Lab',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFFF00),
              onPrimary: Colors.black,
              surface: Color(0xFF1C1C1C),
              onSurface: Colors.white,
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
        },
        "student_Emails": _selectedStudents
      };

      try {
        final response = await _apiService.post('/Lab', labData);
        if (response['success']) {
          if (mounted) {
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
}
