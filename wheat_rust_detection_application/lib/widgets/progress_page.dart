import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/widgets/progress_indicator.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: GifProgressIndicator(width: 150, height: 150),
      ),
    );
  }
}
