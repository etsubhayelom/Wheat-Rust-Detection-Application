// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';

class CreatePostPage extends StatefulWidget {
  final String userId;
  const CreatePostPage({super.key, required this.userId});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _postController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final PostController _postControllerLogic = PostController();

  // Function to pick images from the gallery
  Future<void> _pickImages() async {
    final List<XFile> pickedImages = await ImagePicker().pickMultiImage();
    setState(() {
      _selectedImages.addAll(pickedImages);
    });
  }

  // Function to pick an image from the camera
  Future<void> _pickFromCamera() async {
    final XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _selectedImages.add(pickedImage);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (widget.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID is missing. Please log in again.')),
      );
      return; // Stop the submission
    }
    List<File> files =
        _selectedImages.map((image) => File(image.path)).toList();
    final newPost = await _postControllerLogic.createPost(
      userId: widget.userId,
      text: _postController.text.isEmpty ? null : _postController.text,
      images: files.isEmpty ? null : files,
    );

    if (newPost != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post submitted successfully')));
      _postControllerLogic.fetchPosts();
      Navigator.pop(context, newPost);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("Post",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue),
            onPressed: () {
              _handleSubmit();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Input
            TextField(
              controller: _postController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Type something or record your query",
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 10),

            // Image Previews
            if (_selectedImages.isNotEmpty)
              SizedBox(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _selectedImages.map((img) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(img.path), // Displaying the selected images
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // Audio Record & Gallery Button
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFromCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                  label: const Text(""),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.mic, color: Colors.green),
                  label: const Text("Open Gallery",
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
