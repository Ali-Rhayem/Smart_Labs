import 'package:smart_labs_mobile/models/session_model.dart';

class Lab {
  final String labId;
  final String labCode;
  final String labName;
  final String description;
  final String ppe;
  final List<String> instructors;
  final List<String> students;
  final DateTime date;
  final String startTime;
  final String endTime;
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
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.report,
    required this.semesterId,
    required this.sessions,
  });
}
