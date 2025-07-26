import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';

class CreateArticlePage extends StatefulWidget {
  final String userId;
  const CreateArticlePage({super.key, required this.userId});

  @override
  State<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends State<CreateArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  File? _selectedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitArticle() async {
    if (_titleController.text.isEmpty || _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and text are required')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await PostController().createArticle(
        userId: widget.userId,
        text: _textController.text,
        title: _titleController.text,
        file: _selectedFile,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article posted successfully!')),
      );
      Navigator.pop(context, true); // Go back and refresh articles
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post article: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Article'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _submitArticle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Article Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Article Text'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Attach File'),
                  onPressed: _pickFile,
                ),
                const SizedBox(width: 10),
                if (_selectedFile != null)
                  Text('File: ${_selectedFile!.path.split('/').last}'),
              ],
            ),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
