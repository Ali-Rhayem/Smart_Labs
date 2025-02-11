class StudentSessionData {
  final int id;
  final String name;
  final int attendancePercentage;
  final Map<String, int> ppeCompliance;

  StudentSessionData({
    required this.id,
    required this.name,
    required this.attendancePercentage,
    required this.ppeCompliance,
  });

  factory StudentSessionData.fromJson(Map<String, dynamic> json) {
    return StudentSessionData(
      id: json['id'],
      name: json['name'],
      attendancePercentage: json['attendance_percentage'] ?? 0,
      ppeCompliance: Map<String, int>.from(json['ppE_compliance'] ?? {}),
    );
  }
}

class Session {
  final String id;
  final String labId;
  final DateTime date;
  final String? report;
  final List<StudentSessionData> result;
  final int totalAttendance;
  final Map<String, num> totalPPECompliance;

  Session({
    required this.id,
    required this.labId,
    required this.date,
    this.report,
    required this.result,
    required this.totalAttendance,
    required this.totalPPECompliance,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    final resultList = (json['result'] as List<dynamic>? ?? [])
        .map(
          (value) => StudentSessionData.fromJson(value as Map<String, dynamic>),
        )
        .toList();

    return Session(
      id: json['id'].toString(),
      labId: json['labId'].toString(),
      date: DateTime.parse(json['date']),
      report: json['report'],
      result: resultList,
      totalAttendance: json['totalAttendance'] ?? 0,
      totalPPECompliance:
          Map<String, num>.from(json['totalPPECompliance'] ?? {}),
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
