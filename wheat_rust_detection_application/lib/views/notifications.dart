import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        leading: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            NotificationTile(
              message: 'Researcher Abebe Tequame has answered to your post',
            ),
            NotificationTile(
              message: 'Researcher Abebe Tequame has answered to your post',
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String message;

  const NotificationTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Text(
          message,
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
