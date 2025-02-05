class NotificationModel {
  final int id;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime date;
  final int userId;
  final bool isRead;
  final bool isDeleted;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.data,
    required this.date,
    required this.userId,
    required this.isRead,
    required this.isDeleted,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      data: json['data'],
      date: DateTime.parse(json['date']),
      userId: json['userID'],
      isRead: json['isRead'],
      isDeleted: json['isDeleted'],
    );
  }
}
