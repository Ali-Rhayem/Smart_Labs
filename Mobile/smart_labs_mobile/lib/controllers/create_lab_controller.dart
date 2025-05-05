import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_schedule.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/services/api_service.dart';
import 'package:smart_labs_mobile/utils/date_time_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateLabController {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> submitForm({
    required String labCode,
    required String labName,
    required String description,
    required List<LabSchedule> schedules,
    required String room,
    required List<String> selectedPPEIds,
    required int selectedSemesterId,
    required List<String> selectedStudents,
  }) async {
    final labData = {
      "lab": {
        "labCode": labCode,
        "labName": labName,
        "schedule": schedules.map((s) => s.toJson()).toList(),
        "description": description,
        "endLab": false,
        "room": room,
        "PPE": selectedPPEIds,
        "semesterId": selectedSemesterId,
      },
      "student_Emails": selectedStudents
    };

    try {
      final response = await _apiService.post('/Lab', labData);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create lab: $e',
      };
    }
  }

  void addSchedule({
    required int selectedWeekday,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required Function(LabSchedule) onScheduleAdded,
  }) {
    final schedule = LabSchedule(
      dayOfWeek: getWeekdayName(selectedWeekday),
      startTime: formatTimeToHHMM(startTime),
      endTime: formatTimeToHHMM(endTime),
    );
    onScheduleAdded(schedule);
  }

  bool validateForm({
    required GlobalKey<FormState> formKey,
    required List<String> selectedPPE,
    required List<String> selectedStudents,
    required List<LabSchedule> schedules,
    required BuildContext context,
  }) {
    if (!formKey.currentState!.validate()) return false;

    if (selectedPPE.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select required PPE')),
      );
      return false;
    }

    if (selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one student')),
      );
      return false;
    }

    if (schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one schedule')),
      );
      return false;
    }

    return true;
  }

  Future<void> handleSubmission({
    required WidgetRef ref,
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required List<String> selectedPPE,
    required List<String> selectedStudents,
    required List<LabSchedule> schedules,
    required String labCode,
    required String labName,
    required String description,
    required String room,
    required List<String> selectedPPEIds,
    required int selectedSemesterId,
  }) async {
    if (!validateForm(
      formKey: formKey,
      selectedPPE: selectedPPE,
      selectedStudents: selectedStudents,
      schedules: schedules,
      context: context,
    )) {
      return;
    }

    try {
      final response = await submitForm(
        labCode: labCode,
        labName: labName,
        description: description,
        schedules: schedules,
        room: room,
        selectedPPEIds: selectedPPEIds,
        selectedSemesterId: selectedSemesterId,
        selectedStudents: selectedStudents,
      );

      if (response['success']) {
        if (context.mounted) {
          await ref.read(labsProvider.notifier).fetchLabs();
          Fluttertoast.showToast(
              msg: "Lab created successfully",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          Fluttertoast.showToast(
              msg: response['message'] ?? 'Failed to create lab',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Fluttertoast.showToast(
            msg: 'Failed to create lab: $e',
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
