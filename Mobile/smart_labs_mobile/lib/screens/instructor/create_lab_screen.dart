import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/ppe_povider.dart';
import 'package:smart_labs_mobile/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              _buildTextField(
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
              _buildTextField(
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
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              const SizedBox(height: 16),
              _buildPPEDropdown(),
              const SizedBox(height: 16),
              _buildWeekdaySelector(),
              const SizedBox(height: 16),
              _buildTimeSelectors(),
              const SizedBox(height: 16),
              _buildSchedulesList(),
              const SizedBox(height: 16),
              _buildStudentInput(),
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
              _buildTextField(
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
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
      validator: validator,
    );
  }

  Widget _buildPPEDropdown() {
    return Consumer(
      builder: (context, ref, child) {
        return ref.watch(ppeProvider).when(
              data: (ppeList) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Required PPE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ppeList.map((ppe) {
                        final isSelected =
                            _selectedPPEIds.contains(ppe.id.toString());
                        return FilterChip(
                          label: Text(
                            ppe.name,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedPPEIds.add(ppe.id.toString());
                                logger.w("Selected PPE: ${ppe.name}");
                                logger.w("selected ppe id's ${_selectedPPEIds}");
                                _selectedPPE.add(ppe.name);
                              } else {
                                _selectedPPEIds.remove(ppe.id.toString());
                                _selectedPPE.remove(ppe.name);
                              }
                            });
                          },
                          backgroundColor: const Color(0xFF1C1C1C),
                          selectedColor: const Color(0xFFFFFF00),
                          checkmarkColor: Colors.black,
                          side: const BorderSide(color: Colors.white24),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFFF00),
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading PPE items: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
      },
    );
  }

  Widget _buildWeekdaySelector() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Day of Week',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weekdays.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedWeekday = index + 1;
                    });
                  },
                  child: Container(
                    width: 45,
                    decoration: BoxDecoration(
                      color: _selectedWeekday == index + 1
                          ? const Color(0xFFFFFF00)
                          : const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Center(
                      child: Text(
                        weekdays[index],
                        style: TextStyle(
                          color: _selectedWeekday == index + 1
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lab Schedule',
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
              child: InkWell(
                onTap: () => _selectTime(true),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Time',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _startTime.format(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(false),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Time',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _endTime.format(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildStudentInput() {
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
                controller: _studentInputController,
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
              onPressed: () {
                if (_studentInputController.text.isNotEmpty) {
                  setState(() {
                    _selectedStudents.add(_studentInputController.text);
                    _studentInputController.clear();
                  });
                }
              },
              icon: const Icon(Icons.add, color: Color(0xFFFFFF00)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedStudents.map((student) {
            return Chip(
              label: Text(
                student,
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: const Color(0xFFFFFF00),
              side: const BorderSide(color: Colors.black),
              labelStyle: const TextStyle(color: Colors.black),
              deleteIcon:
                  const Icon(Icons.close, size: 18, color: Colors.black),
              onDeleted: () {
                setState(() {
                  _selectedStudents.remove(student);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSchedulesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedules',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._schedules
            .map((schedule) => Card(
                  color: const Color(0xFF1C1C1C),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      '${schedule.dayOfWeek}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${schedule.startTime} - ${schedule.endTime}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _schedules.remove(schedule);
                        });
                      },
                    ),
                  ),
                ))
            .toList(),
        ElevatedButton.icon(
          onPressed: _addSchedule,
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text('Add Schedule'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFFF00),
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
  }

  void _addSchedule() {
    setState(() {
      _schedules.add(
        LabSchedule(
          dayOfWeek: _getWeekdayName(_selectedWeekday),
          startTime: _formatTimeToHHMM(_startTime),
          endTime: _formatTimeToHHMM(_endTime),
        ),
      );
    });
  }

  String _formatTimeToHHMM(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
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
          "ppeIds": _selectedPPEIds,
        },
        "student_Emails": _selectedStudents
      };

      try {
        final response = await _apiService.post('/Lab', labData);
        if (response['success']) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? 'Failed to create lab')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create lab: $e')),
        );
      }
    }
  }
}
