import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/services/api_services.dart';

final List<Map<String, String>> guidelines = [
  {
    "key": "inaccurate_diagnosis",
    "title": "Inaccurate Diagnosis",
  },
  {
    "key": "offensive_content",
    "title": "Offensive or Inappropriate Content",
  },
  {
    "key": "spam_irrelevant",
    "title": "Spam or Irrelevant Content",
  },
  {
    "key": "duplicate_post",
    "title": "Duplicate or Repetitive Post",
  },
  {
    "key": "misleading_image",
    "title": "Misleading or Fake Image",
  },
  {
    "key": "unverified_article",
    "title": "Unverified Expert Content",
  },
  {
    "key": "privacy_violation",
    "title": "Privacy Violation",
  },
];

class ReportDialog extends StatefulWidget {
  final String postId;
  final ApiService apiService;
  const ReportDialog(
      {super.key, required this.postId, required this.apiService});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedKey;
  bool _isSubmitting = false;

  Future<void> _submitReport() async {
    if (_selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a reason to report')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    try {
      final response = await widget.apiService
          .reportPost(postId: widget.postId, reportType: _selectedKey!);

      debugPrint('Report API response status: ${response.statusCode}');
      debugPrint('Report API response body: ${response.body}');
      setState(() {
        _isSubmitting = false;
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit report')));
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      debugPrint('Error submitting report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting report')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Post'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: guidelines.map((option) {
              return RadioListTile<String>(
                value: option['key']!,
                groupValue: _selectedKey,
                onChanged: (value) {
                  setState(() {
                    _selectedKey = value;
                  });
                },
                title: Text(option['title']!),
                subtitle: option['description'] == null
                    ? null
                    : Text(option['description']!),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReport,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Submit')),
      ],
    );
  }
}
