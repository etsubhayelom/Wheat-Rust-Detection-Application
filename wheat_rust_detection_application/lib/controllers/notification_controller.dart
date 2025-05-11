import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/models/notification_model.dart';
import 'package:wheat_rust_detection_application/api_services.dart';

class NotificationController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchNotifications() async {
    _loading = true;
    notifyListeners();
    final response = await _apiService.fetchNotificationsFromApi();
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _notifications = data.map((n) => AppNotification.fromJson(n)).toList();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int notificationId) async {
    final response = await _apiService.markNotificationAsRead(notificationId);
    if (response.statusCode == 200) {
      _notifications = _notifications.map((n) {
        if (n.id == notificationId) {
          return AppNotification(
            id: n.id,
            title: n.title,
            body: n.body,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      notifyListeners();
    }
  }
}
