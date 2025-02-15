import 'package:smart_labs_mobile/models/lab_schedule.dart';
import 'package:smart_labs_mobile/models/session_model.dart';

class Lab {
  final String labId;
  final String labCode;
  final String labName;
  final String description;
  final String ppe;
  final String? room;
  final List<String> instructors;
  final List<String> students;
  final List<LabSchedule> schedule;
  final String report;
  final String semesterId;
  final List<Session> sessions;
  final bool started;

  const Lab({
    required this.labId,
    required this.labCode,
    required this.labName,
    required this.description,
    required this.ppe,
    this.room,
    required this.instructors,
    required this.students,
    required this.schedule,
    required this.report,
    required this.semesterId,
    required this.sessions,
    required this.started,
  });
}
