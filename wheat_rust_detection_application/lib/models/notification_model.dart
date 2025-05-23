class AppNotification {
  final int id;
  final String senderName;
  final String notificationType;
  final int? post;
  final int? comment;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.senderName,
    required this.notificationType,
    this.post,
    this.comment,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      senderName: json['sender_name'] ?? '',
      notificationType: json['notification_type'] ?? '',
      post: json['post'],
      comment: json['comment'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
