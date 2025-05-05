class LabAnalytics {
  final int totalAttendance;
  final List<int> totalAttendanceByTime;
  final int totalPPECompliance;
  final List<int> totalPPEComplianceByTime;
  final Map<String, int> ppeCompliance;
  final Map<String, List<int>> ppeComplianceByTime;
  final List<StudentAnalytics> people;
  final List<StudentAnalyticsTime> peopleByTime;

  LabAnalytics.fromJson(Map<String, dynamic> json)
      : totalAttendance = json['total_attendance'] ?? 0,
        totalAttendanceByTime =
            List<int>.from(json['total_attendance_bytime'] ?? []),
        totalPPECompliance = json['total_ppe_compliance'] ?? 0,
        totalPPEComplianceByTime =
            List<int>.from(json['total_ppe_compliance_bytime'] ?? []),
        ppeCompliance = Map<String, int>.from(json['ppe_compliance'] ?? {}),
        ppeComplianceByTime =
            (json['ppe_compliance_bytime'] as Map<String, dynamic>? ?? {})
                .map((key, value) => MapEntry(key, List<int>.from(value))),
        people = (json['people'] as List? ?? [])
            .map((e) => StudentAnalytics.fromJson(e))
            .toList(),
        peopleByTime = (json['people_bytime'] as List? ?? [])
            .map((e) => StudentAnalyticsTime.fromJson(e))
            .toList();
}

class StudentAnalytics {
  final int id;
  final String name;
  final UserInfo user;
  final int attendancePercentage;
  final Map<String, int> ppeCompliance;

  StudentAnalytics.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        user = UserInfo.fromJson(json['user']),
        attendancePercentage = json['attendance_percentage'] ?? 0,
        ppeCompliance = Map<String, int>.from(json['ppE_compliance'] ?? {});
}

class StudentAnalyticsTime {
  final int id;
  final String name;
  final UserInfo user;
  final List<int> attendancePercentage;
  final Map<String, List<int>> ppeCompliance;

  StudentAnalyticsTime.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        user = UserInfo.fromJson(json['user']),
        attendancePercentage =
            List<int>.from(json['attendance_percentage'] ?? []),
        ppeCompliance = (json['ppE_compliance'] as Map<String, dynamic>? ?? {})
            .map((key, value) => MapEntry(key, List<int>.from(value)));
}

class UserInfo {
  final int id;
  final String name;
  final String email;
  final String? major;
  final String? faculty;
  final String? image;

  UserInfo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        email = json['email'],
        major = json['major'],
        faculty = json['faculty'],
        image = json['image'];
}
