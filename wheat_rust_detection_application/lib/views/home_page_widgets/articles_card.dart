import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  final String title;
  final String text;
  final String? fileName;
  final VoidCallback? onDownload;

  const ArticleCard({
    super.key,
    required this.title,
    required this.text,
    this.fileName,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange[300],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Just now',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 15)),
            if (fileName != null && onDownload != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: Text('Download $fileName'),
                  onPressed: onDownload,
                ),
              ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  onPressed: () {
                    // Implement like logic
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    // Implement comment logic
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () {
                    // Implement download logic
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
