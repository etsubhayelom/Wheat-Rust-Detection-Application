import 'package:flutter/material.dart';

class GifProgressIndicator extends StatelessWidget {
  final double width;
  final double height;
  const GifProgressIndicator(
      {super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/loading.gif',
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
