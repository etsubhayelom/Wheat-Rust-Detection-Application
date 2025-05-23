import 'package:flutter/material.dart';

class FeedbackDialog extends StatefulWidget {
  final Function(
    int rating,
    String comment,
    String aiAccuracy,
  ) onSubmit;

  const FeedbackDialog({super.key, required this.onSubmit});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _rating = 3;
  String _comment = '';
  String _aiAccuracy = 'Accurate';
  final _commentController = TextEditingController();

  final List<String> _accuracyOptions = [
    'Accurate',
    'Not Accurate',
    'Other Feedback',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thank you for your feedback!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 18),
            const Text("Rate our app"),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border_outlined,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  iconSize: 32,
                  padding: EdgeInsets.zero,
                );
              }),
            ),
            const SizedBox(height: 10),
            const Text("Comment"),
            const SizedBox(height: 4),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    "Your thought matters! Feel free to leave us comments.",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _comment = val),
            ),
            const SizedBox(height: 12),
            const Text("AI Accuracy"),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _aiAccuracy,
              items: _accuracyOptions
                  .map((opt) => DropdownMenuItem(
                        value: opt,
                        child: Text(opt),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _aiAccuracy = val);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  widget.onSubmit(
                    _rating,
                    _commentController.text,
                    _aiAccuracy,
                  );
                  Navigator.pop(context, true);
                },
                child: const Text(
                  "Submit",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
