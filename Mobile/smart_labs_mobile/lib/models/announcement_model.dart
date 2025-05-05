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
  List<Submission>? submissions;

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
  final int userId;
  final User user;
  final String message;
  final List<String> files;
  final DateTime submittedAt;
  final bool submitted;
  final int? grade;

  Submission({
    required this.userId,
    required this.user,
    required this.message,
    required this.files,
    required this.submittedAt,
    required this.submitted,
    this.grade,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      userId: json['userId'],
      user: User.fromJson(json['user'] ?? {}),
      message: json['message'] ?? '',
      files: List<String>.from(json['files'] ?? []),
      submittedAt:
          json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      submitted: json['submitted'] ?? false,
      grade: json['grade'],
    );
  }

  Submission copyWith({
    String? userId,
    User? user,
    String? message,
    List<String>? files,
    DateTime? submittedAt,
    bool? submitted,
    int? grade,
  }) {
    return Submission(
      userId: int.parse(userId ?? this.userId.toString()),
      user: user ?? this.user,
      message: message ?? this.message,
      files: files ?? this.files,
      submittedAt: submittedAt ?? this.submittedAt,
      submitted: submitted ?? this.submitted,
      grade: grade ?? this.grade,
    );
  }
}
