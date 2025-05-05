class Semester {
  final int id;
  final String name;
  final bool currentSemester;

  Semester({
    required this.id,
    required this.name,
    required this.currentSemester,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'],
      name: json['name'],
      currentSemester: json['currentSemester'],
    );
  }
}
