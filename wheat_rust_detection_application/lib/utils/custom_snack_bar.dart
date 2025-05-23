import 'package:flutter/material.dart';

class CustomSnackBarContent extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  const CustomSnackBarContent(
      {super.key,
      required this.title,
      required this.message,
      required this.backgroundColor,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(message, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    bool isError = false,
  }) {
    final snackBar = SnackBar(
      content: CustomSnackBarContent(
        title: title,
        message: message,
        icon: isError ? Icons.error : Icons.info,
        backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
      ),
      backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
