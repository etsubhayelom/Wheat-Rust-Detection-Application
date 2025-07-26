import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';
import 'package:wheat_rust_detection_application/models/post_model.dart';

class ArticleCard extends StatelessWidget {
  final Post post;
  final PostController postController;
  final String title;
  final String text;
  final String? fileName;

  const ArticleCard({
    super.key,
    required this.title,
    required this.text,
    required this.post,
    required this.postController,
    this.fileName,
  });

  Future<bool> checkStoragePermission(BuildContext context) async {
    var status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied || status.isRestricted || status.isLimited) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Storage permission permanently denied. Please enable it in settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
    return false;
  }

  Future<void> _downloadFile(BuildContext context) async {
    if (post.file == null || post.file!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No file to download')));
      return;
    }

    if (!await checkStoragePermission(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    try {
      final dio = Dio();

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
      if (directory == null) {
        throw Exception('Cannot access storage');
      }

      final savePath =
          '${directory.path}/${fileName ?? _extractFileName(post.file!)}';

      await dio.download(post.file!, savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          debugPrint(
              'Downloading: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to $savePath')));
    } catch (e) {
      debugPrint('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
    }
  }

  String _extractFileName(String url) {
    try {
      return Uri.parse(url).pathSegments.last;
    } catch (_) {
      return 'file';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = post.file != null && post.file!.isNotEmpty;
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
                  child: const Icon(Icons.person, color: Colors.black),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('article posted about wheat rust',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 15)),
            if (hasFile)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: Text(
                      'Download ${fileName ?? _extractFileName(post.file!)}'),
                  onPressed: () => _downloadFile(context),
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
                if (hasFile)
                  IconButton(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: () => _downloadFile(context),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
