import 'package:smart_labs_mobile/models/user_model.dart';

class Comment {
  final int id;
  final User user;
  final String message;
  final DateTime time;

  Comment({
    required this.id,
    required this.user,
    required this.message,
    required this.time,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      user: User.fromJson(json['user']),
      message: json['message'],
      time: DateTime.parse(json['time']),
    );
  }
}
