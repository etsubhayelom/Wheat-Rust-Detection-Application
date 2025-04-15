// Reusable Card Widget
import 'package:flutter/material.dart';

class BlogCard extends StatelessWidget {
  final String title;
  final String description;
  final String timeAgo;
  // final String imageUrl;

  const BlogCard({
    super.key,
    required this.title,
    required this.description,
    required this.timeAgo,
    // required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              'assets/splash1.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timeAgo,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description Section
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                // Action Buttons (like, comment, share)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
