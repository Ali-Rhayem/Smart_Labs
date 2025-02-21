import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/models/lab_schedule.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/widgets/lab_schedules_list.dart';
import 'package:smart_labs_mobile/widgets/ppe_dropdwon.dart';
import 'package:smart_labs_mobile/widgets/time_selectors.dart';
import 'package:smart_labs_mobile/widgets/week_day_selector.dart';
import 'package:smart_labs_mobile/providers/room_provider.dart';
import 'package:smart_labs_mobile/utils/date_time_utils.dart';
import 'package:smart_labs_mobile/providers/semester_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

var logger = Logger();

class EditLabScreen extends ConsumerStatefulWidget {
  final Lab lab;

  const EditLabScreen({super.key, required this.lab});

  @override
  ConsumerState<EditLabScreen> createState() => _EditLabScreenState();
}

class _EditLabScreenState extends ConsumerState<EditLabScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labNameController;
  late TextEditingController _labCodeController;
  late TextEditingController _descriptionController;
  late TextEditingController _roomController;
  late TextEditingController _semesterController;
  late List<LabSchedule> _schedules;

  int _selectedWeekday = DateTime.now().weekday;
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  final ApiService _apiService = ApiService();

  final List<String> _selectedPPEIds = [];
  late int _selectedSemesterId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _labNameController = TextEditingController(text: widget.lab.labName);
    _labCodeController = TextEditingController(text: widget.lab.labCode);
    _descriptionController =
        TextEditingController(text: widget.lab.description);
    _roomController = TextEditingController(text: widget.lab.room ?? '');
    _semesterController = TextEditingController();
    _schedules = List.from(widget.lab.schedule);
    _selectedSemesterId = int.parse(widget.lab.semesterId);

    // Initialize selected PPE IDs from the lab's ppeIds
    _selectedPPEIds.addAll(widget.lab.ppeIds);
  }

  @override
  void dispose() {
    _labNameController.dispose();
    _labCodeController.dispose();
    _descriptionController.dispose();
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
        title: const Text('Edit Lab'),
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
                  });
                },
                onRemovePPE: (ppeId, ppeName) {
                  setState(() {
                    _selectedPPEIds.remove(ppeId);
                  });
                },
              ),
              const SizedBox(height: 16),
              WeekdaySelector(
                selectedWeekday: _selectedWeekday,
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
                onAddSchedule: _addSchedule,
                onRemoveSchedule: (schedule) {
                  setState(() {
                    _schedules.remove(schedule);
                  });
                },
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
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
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.black
                                : theme.colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showDeleteConfirmation(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Delete Lab',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
        labelStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
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
          data: (rooms) {
            // Make sure the current room is in the list
            if (_roomController.text.isNotEmpty &&
                !rooms.any((room) => room.name == _roomController.text)) {
              rooms = [...rooms];
              rooms.add(Room(id: '-1', name: _roomController.text));
            }

            return DropdownButtonFormField<String>(
              value:
                  _roomController.text.isNotEmpty ? _roomController.text : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1C1C1C)
                    : theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              items: rooms.map((room) {
                return DropdownMenuItem(
                  value: room.name,
                  child: Text(room.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _roomController.text = value ?? '';
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a room' : null,
            );
          },
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
          data: (semesters) {
            return DropdownButtonFormField<int>(
              value: _selectedSemesterId,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1C1C1C)
                    : theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
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
                if (value != null) {
                  setState(() {
                    _selectedSemesterId = value;
                  });
                }
              },
              validator: (value) =>
                  value == null ? 'Please select a semester' : null,
            );
          },
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        if (_selectedPPEIds.isEmpty) {
          Fluttertoast.showToast(
              msg: 'Please select required PPE',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              fontSize: 16.0);
          return;
        }

        // Check if any changes were made to the lab data
        bool hasLabChanges = _labNameController.text != widget.lab.labName ||
            _labCodeController.text != widget.lab.labCode ||
            _descriptionController.text != widget.lab.description ||
            _roomController.text != (widget.lab.room ?? '') ||
            _selectedSemesterId != int.parse(widget.lab.semesterId) ||
            !_areSchedulesEqual(_schedules, widget.lab.schedule);

        // Check if PPE changed
        bool hasPPEChanges =
            !_areListsEqual(_selectedPPEIds, widget.lab.ppeIds);

        if (!hasLabChanges && !hasPPEChanges) {
          if (mounted) {
            Navigator.pop(context);
          }
          return;
        }

        bool success = true;
        String errorMessage = '';

        // Only update lab details if there are changes
        if (hasLabChanges) {
          final labData = {
            "labCode": _labCodeController.text,
            "labName": _labNameController.text,
            "schedule": _schedules.map((s) => s.toJson()).toList(),
            "description": _descriptionController.text,
            "endLab": false,
            "room": _roomController.text,
            "semesterId": _selectedSemesterId,
          };

          final labResponse =
              await _apiService.put('/Lab/${widget.lab.labId}', labData);
          if (!labResponse['success']) {
            success = false;
            errorMessage = labResponse['message'] ?? 'Failed to update lab';
          }
        }

        // Only update PPE if there are changes and lab update was successful
        if (success && hasPPEChanges) {
          final ppeResponse = await _apiService.postRaw(
            '/Lab/${widget.lab.labId}/ppe',
            _selectedPPEIds,
          );

          if (!ppeResponse['success']) {
            success = false;
            errorMessage = ppeResponse['message'] ?? 'Failed to update PPE';
          }
        }

        if (success) {
          if (mounted) {
            await ref.read(labsProvider.notifier).fetchLabs();
            Navigator.pop(context);
            Fluttertoast.showToast(
                msg: "Lab updated successfully",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        } else {
          if (mounted) {
            Fluttertoast.showToast(
                msg: errorMessage,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
              msg: 'Failed to update lab: $e',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Helper method to compare schedules
  bool _areSchedulesEqual(List<LabSchedule> a, List<LabSchedule> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].dayOfWeek != b[i].dayOfWeek ||
          a[i].startTime != b[i].startTime ||
          a[i].endTime != b[i].endTime) {
        return false;
      }
    }
    return true;
  }

  // Helper method to compare lists
  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final setA = Set.from(a);
    final setB = Set.from(b);
    return setA.difference(setB).isEmpty && setB.difference(setA).isEmpty;
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        title: Text(
          'Delete Lab',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete this lab? This action cannot be undone.',
          style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        if (!context.mounted) return;

        final response =
            await ref.read(labsProvider.notifier).deleteLab(widget.lab.labId);

        if (!context.mounted) return;

        if (response['success']) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Fluttertoast.showToast(
              msg: response['message'] ?? 'Lab deleted successfully',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: response['message'] ?? 'Failed to delete lab',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } catch (e) {
        if (!context.mounted) return;
        Fluttertoast.showToast(
            msg: 'Error: $e',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }
}
