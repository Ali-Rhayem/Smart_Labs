class StudentSessionData {
  final String name;
  final int attendancePercentage;
  final Map<String, int> ppeCompliance;

  StudentSessionData({
    required this.name,
    required this.attendancePercentage,
    required this.ppeCompliance,
  });

  factory StudentSessionData.fromJson(Map<String, dynamic> json) {
    return StudentSessionData(
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
  final Map<String, StudentSessionData> result;
  final int totalAttendance;
  final Map<String, int> totalPPECompliance;

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
    final resultMap = (json['result'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(
        key,
        StudentSessionData.fromJson(value as Map<String, dynamic>),
      ),
    );

    return Session(
      id: json['id'].toString(),
      labId: json['labId'].toString(),
      date: DateTime.parse(json['date']),
      report: json['report'],
      result: resultMap,
      totalAttendance: json['totalAttendance'] ?? 0,
      totalPPECompliance:
          Map<String, int>.from(json['totalPPECompliance'] ?? {}),
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
