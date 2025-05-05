class DashboardAnalytics {
  final int totalStudents;
  final int totalLabs;
  final double avgAttendance;
  final double ppeCompliance;
  final List<LabDashboardAnalytics> labs;

  DashboardAnalytics.fromJson(Map<String, dynamic> json)
      : totalStudents = json['total_students'] ?? 0,
        totalLabs = json['total_labs'] ?? 0,
        avgAttendance = (json['avg_attandance'] ?? 0).toDouble(),
        ppeCompliance = (json['ppe_compliance'] ?? 0).toDouble(),
        labs = (json['labs'] as List? ?? [])
            .map((e) => LabDashboardAnalytics.fromJson(e))
            .toList();
}

class LabDashboardAnalytics {
  final String labId;
  final String labName;
  final int totalAttendance;
  final List<int> totalAttendanceByTime;
  final int totalPPECompliance;
  final List<int> totalPPEComplianceByTime;
  final Map<String, int> ppeCompliance;
  final Map<String, List<int>> ppeComplianceByTime;
  final List<String> xaxis;

  LabDashboardAnalytics.fromJson(Map<String, dynamic> json)
      : labId = json['lab_id']?.toString() ?? '',
        labName = json['lab_name'] ?? '',
        totalAttendance = json['total_attendance'] ?? 0,
        totalAttendanceByTime =
            List<int>.from(json['total_attendance_bytime'] ?? []),
        totalPPECompliance = json['total_ppe_compliance'] ?? 0,
        totalPPEComplianceByTime =
            List<int>.from(json['total_ppe_compliance_bytime'] ?? []),
        ppeCompliance = Map<String, int>.from(json['ppe_compliance'] ?? {}),
        ppeComplianceByTime =
            (json['ppe_compliance_bytime'] as Map<String, dynamic>? ?? {})
                .map((key, value) => MapEntry(key, List<int>.from(value))),
        xaxis = List<String>.from(json['xaxis'] ?? []);
}
