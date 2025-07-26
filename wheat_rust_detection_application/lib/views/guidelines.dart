import 'package:flutter/material.dart';

class GuidelinesPage extends StatelessWidget {
  const GuidelinesPage({super.key});

  final List<Map<String, String>> guidelines = const [
    {
      "key": "inaccurate_diagnosis",
      "title": "Inaccurate Diagnosis",
      "description":
          "Posts must not contain incorrect or misleading information about wheat rust or other crop diseases. Share only verified observations or ask genuine questions."
    },
    {
      "key": "offensive_content",
      "title": "Offensive or Inappropriate Content",
      "description":
          "Avoid using offensive language, personal attacks, or sharing inappropriate images. This is a respectful space for farmers and experts."
    },
    {
      "key": "spam_irrelevant",
      "title": "Spam or Irrelevant Content",
      "description":
          "Please avoid posting content that is promotional, irrelevant to wheat rust, or does not add value to the discussion."
    },
    {
      "key": "duplicate_post",
      "title": "Duplicate or Repetitive Post",
      "description":
          "Avoid posting the same question or image multiple times. Check existing posts before creating a new one."
    },
    {
      "key": "misleading_image",
      "title": "Misleading or Fake Image",
      "description":
          "Do not upload edited, unrelated, or fake images claiming to show wheat rust. Posts must be based on real field observations."
    },
    {
      "key": "unverified_article",
      "title": "Unverified Expert Content",
      "description":
          "Articles or in-depth posts must be written by verified experts or researchers. Do not impersonate an expert."
    },
    {
      "key": "privacy_violation",
      "title": "Privacy Violation",
      "description":
          "Do not post identifiable images of people or private farms without permission. Respect others' privacy and data."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Guidelines'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: guidelines.length,
        itemBuilder: (context, index) {
          final guideline = guidelines[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guideline['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    guideline['description'] ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
