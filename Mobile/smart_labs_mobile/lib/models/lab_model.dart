import 'package:smart_labs_mobile/models/session_model.dart';

class Lab {
  final String labId;
  final String labCode;
  final String labName;
  final String description;
  final String ppe;
  final List<String> instructors;
  final List<String> students;
  final List<LabSchedule> schedule;
  final String report;
  final String semesterId;
  final List<Session> sessions;

  const Lab({
    required this.labId,
    required this.labCode,
    required this.labName,
    required this.description,
    required this.ppe,
    required this.instructors,
    required this.students,
    required this.schedule,
    required this.report,
    required this.semesterId,
    required this.sessions,
  });
}

class LabSchedule {
  String dayOfWeek;
  String startTime;
  String endTime;

  LabSchedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
  };
}