class Session {
  final String id;
  final String labId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String description;
  final List<StudentRecord> output; // or a custom type
  final String report;

  Session({
    required this.id,
    required this.labId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.output,
    required this.report,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'].toString(),
      labId: json['labId'].toString(),
      date: DateTime.parse(json['date']),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      description: json['description'] ?? '',
      output: [],
      report: json['report'] ?? '',
    );
  }
}

// student record example just for testing
class StudentRecord {
  final String studentId;
  final String studentName;
  final bool attendance;
  final bool ppe;

  StudentRecord({
    required this.studentId,
    required this.studentName,
    required this.attendance,
    required this.ppe,
  });
}
