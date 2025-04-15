import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool popularPostsNotification = true;
  bool answerNotification = true;

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
              Navigator.of(context).pop();
            },
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(),
          ),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Section
            const Text(
              "General",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Select your language",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              "English",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const Divider(),

            // Notifications Section
            const SizedBox(height: 16),
            const Text(
              "Notifications",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),
            _buildNotificationItem(
              title: "Popular Posts",
              subtitle: "Receive Push Notification",
              value: popularPostsNotification,
              onChanged: (val) {
                setState(() {
                  popularPostsNotification = val;
                });
              },
            ),
            const Divider(),
            _buildNotificationItem(
              title: "Answer to your post",
              subtitle: "Receive Push Notification",
              value: answerNotification,
              onChanged: (val) {
                setState(() {
                  answerNotification = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Transform.scale(
              scale: 0.8, // Adjust this value to change the size
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.green,
              ),
            )
          ],
        ),
      ],
    );
  }
}
