import 'package:smart_labs_mobile/models/comment_model.dart';
import 'package:smart_labs_mobile/models/user_model.dart';

class Announcement {
  final int id;
  final User user;
  final String message;
  final List<String> files;
  final DateTime time;
  final List<Comment> comments;

  Announcement({
    required this.id,
    required this.user,
    required this.message,
    required this.files,
    required this.time,
    required this.comments,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      user: User.fromJson(json['user']),
      message: json['message'],
      files: List<String>.from(json['files'] ?? []),
      time: DateTime.parse(json['time']),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((comment) => Comment.fromJson(comment))
          .toList(),
    );
  }
}
