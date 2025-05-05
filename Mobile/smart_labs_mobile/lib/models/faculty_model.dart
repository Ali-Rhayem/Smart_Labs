class Faculty {
  final int id;
  final String faculty;
  final List<String> major;

  Faculty({required this.id, required this.faculty, required this.major});

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'],
      faculty: json['faculty'],
      major: (json['major'] as List).map((e) => e.toString()).toList(),
    );
  }
}