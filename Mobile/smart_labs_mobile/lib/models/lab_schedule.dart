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
}