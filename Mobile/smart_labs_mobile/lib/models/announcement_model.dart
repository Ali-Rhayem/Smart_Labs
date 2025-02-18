import 'package:smart_labs_mobile/models/comment_model.dart';
import 'package:smart_labs_mobile/models/user_model.dart';

class Announcement {
  final int id;
  final User user;
  final String message;
  final List<String> files;
  final DateTime time;
  List<Comment> comments = [];
  final bool isAssignment;
  final bool canSubmit;
  final DateTime? deadline;
  final int? grade;
  final List<Submission>? submissions;

  Announcement({
    required this.id,
    required this.user,
    required this.message,
    required this.files,
    required this.time,
    required this.comments,
    this.isAssignment = false,
    this.canSubmit = false,
    this.deadline,
    this.grade,
    this.submissions,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      user: User.fromJson(json['user'] ?? {}),
      message: json['message'] ?? '',
      files: List<String>.from(json['files'] ?? []),
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((comment) => Comment.fromJson(comment))
          .toList(),
      isAssignment: json['assignment'] ?? false,
      canSubmit: json['canSubmit'] ?? false,
      deadline:
          json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      grade: json['grade'],
      submissions: json['submissions'] != null
          ? (json['submissions'] as List<dynamic>)
              .where((s) => s != null)
              .map((s) => Submission.fromJson(s))
              .toList()
          : null,
    );
  }
}

class Submission {
  final User user;
  final int? grade;
  final List<String> files;
  final DateTime submittedAt;

  Submission({
    required this.user,
    this.grade,
    required this.files,
    required this.submittedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      user: User.fromJson(json['user'] ?? {}),
      grade: json['grade'],
      files: List<String>.from(json['files'] ?? []),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : DateTime.now(),
    );
  }
}
