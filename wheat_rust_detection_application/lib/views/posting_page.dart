// ignore_for_file: library_private_types_in_public_api

import 'dart:core';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';
import 'package:wheat_rust_detection_application/views/audio_preview.dart';

class CreatePostPage extends StatefulWidget {
  final String userId;

  const CreatePostPage({super.key, required this.userId});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final record = AudioRecorder();
  late FocusNode _textFieldFocusNode;
  final TextEditingController _postController = TextEditingController();

  final List<XFile> _selectedImages = [];
  final PostController _postControllerLogic = PostController();

  String? _audioFilePath;
  bool _isRecording = false;

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

  Future<void> _startRecording() async {
    bool hasPermission = await record.hasPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

    await record.start(
      const RecordConfig(),
      path: filePath,
    );

    setState(() {
      _audioFilePath = filePath;
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    final path = await record.stop();

    setState(() {
      _isRecording = false;
      _audioFilePath = path;
    });

    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording saved')),
      );
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
    List<File> files = _selectedImages.map((e) => File(e.path)).toList();
    File? audioFile = _audioFilePath != null ? File(_audioFilePath!) : null;

    final newPost = await _postControllerLogic.createPost(
      userId: widget.userId,
      text: _postController.text.isEmpty ? null : _postController.text,
      images: files.isEmpty ? null : files,
      audio: audioFile,
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
  void initState() {
    super.initState();

    _textFieldFocusNode = FocusNode();
    // Request focus after a tiny delay to ensure widget is built
    Future.delayed(Duration.zero, () => _textFieldFocusNode.requestFocus());
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.post,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
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
                focusNode: _textFieldFocusNode,
                autofocus: true,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!
                      .typeSomeThingOrRecordYourQuery,
                  border: InputBorder.none,
                ),
              ),

              if (_audioFilePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: AudioPreviewPlayer(
                    audioFilePath: _audioFilePath!,
                    onDelete: () {
                      setState(() {
                        _audioFilePath = null;
                      });
                    },
                  ),
                ),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.red : Colors.white,
                    ),
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic,
                        size: 40,
                        color: _isRecording ? Colors.white : Colors.green),
                    // label: Text(_isRecording ? "Stop Recording" : "",
                    //     style: TextStyle(
                    //         color: _isRecording ? Colors.white : Colors.green)),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: _pickImages,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.openGallery,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_right,
                              color: Colors.green, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _pickFromCamera,
                      child: Container(
                        width: 100,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(_selectedImages[index].path),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
