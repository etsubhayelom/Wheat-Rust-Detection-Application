import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KnowTheDiseasePage extends StatefulWidget {
  const KnowTheDiseasePage({super.key});

  @override
  State<KnowTheDiseasePage> createState() => _KnowTheDiseasePageState();
}

class _KnowTheDiseasePageState extends State<KnowTheDiseasePage> {
  File? _image;
  final picker = ImagePicker();

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        debugPrint('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        debugPrint('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview (replace with your actual camera implementation)
          if (_image != null)
            Image.file(
              _image!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else
            const Center(
                child: Text(
              'Camera Preview',
              style: TextStyle(color: Colors.white),
            )),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.image,
                      color: Colors.white, size: 30), // Gallery Icon
                  onPressed: getImageFromGallery,
                ),
                ElevatedButton(
                  onPressed: getImageFromCamera,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 40, color: Colors.black), // Camera Shutter
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline,
                      color: Colors.white, size: 30), // Help Icon
                  onPressed: () {
                    // Help action
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 20,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white, size: 30),
              onPressed: () {
                // Toggle flash
              },
            ),
          ),
        ],
      ),
    );
  }
}
