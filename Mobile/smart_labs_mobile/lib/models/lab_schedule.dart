class LabSchedule {
  final String dayOfWeek;
  final String startTime;
  final String endTime;

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

  factory LabSchedule.fromJson(Map<String, dynamic> json) {
    return LabSchedule(
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}
