import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheat_rust_detection_application/models/notification_model.dart';
import '../controllers/notification_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String getNotificationMessage(AppNotification notification) {
    switch (notification.notificationType) {
      case 'verification':
        return '${notification.senderName} sent you a verification notification.';
      case 'like':
        return '${notification.senderName} liked your post.';
      // Add more cases as needed
      default:
        return 'You have a new notification.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Consumer<NotificationController>(
        builder: (context, controller, _) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return ListTile(
                title: Text(getNotificationMessage(notification)),
                subtitle: Text('Received at: ${notification.createdAt}'),
                trailing: notification.isRead
                    ? null
                    : const Icon(Icons.circle, color: Colors.blue, size: 12),
                onTap: () {
                  if (!notification.isRead) {
                    controller.markAsRead(notification.id);
                  }
                  // Optionally: Navigate to a detail page
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () {
          Provider.of<NotificationController>(context, listen: false)
              .fetchNotifications();
        },
      ),
    );
  }
}
