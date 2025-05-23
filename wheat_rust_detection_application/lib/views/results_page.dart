import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:wheat_rust_detection_application/services/api_services.dart';
import 'package:wheat_rust_detection_application/views/feedback_dialog.dart';
import 'package:wheat_rust_detection_application/views/posting_page.dart'; // Add image package for image processing

class ResultPage extends StatefulWidget {
  final File imageFile;

  const ResultPage({
    super.key,
    required this.imageFile,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Interpreter _rustInterpreter;
  late Interpreter _wheatInterpreter;
  final ApiService apiService = ApiService();
  String _predictedLabel = "Detecting...";
  double _confidence = 0.0;
  bool _isProcessing = true;
  String? userId;

  // final List<String> _wheatLabels = ["not_wheat", "wheat"];
  final List<String> _rustLabels = [
    "Healthy",
    "Yellow Rust",
    "Brown Rust",
    "Black Rust"
  ];

  final Map<String, dynamic> _diagnosisInfo = {
    "Yellow Rust": {
      "severity": "Moderate",
      "symptoms": [
        "Yellow pustules on leaf surface",
        "Chlorotic spots on leaves",
        "Premature leaf senescence",
      ],
      "treatment": [
        "Apply fungicides containing chlorothalonil or mancozeb",
        "Ensure good air circulation",
        "Remove infected plant debris",
      ],
    },
    "Brown Rust": {
      "severity": "Severe",
      "symptoms": [
        "Brown pustules on leaf surface",
        "Leaf curling and drying",
        "Reduced grain yield",
      ],
      "treatment": [
        "Use resistant wheat varieties",
        "Apply appropriate fungicides early",
        "Crop rotation to reduce inoculum",
      ],
    },
    "Black Rust": {
      "severity": "High",
      "symptoms": [
        "Black pustules on stems and leaves",
        "Stem breakage and lodging",
        "Severe yield loss",
      ],
      "treatment": [
        "Use resistant cultivars",
        "Apply fungicides promptly",
        "Monitor fields regularly",
      ],
    },
    "Healthy": {
      "severity": "None",
      "symptoms": [
        "No visible rust symptoms",
      ],
      "treatment": [
        "Maintain good crop management practices",
      ],
    },
    // Add more disease info here if needed
  };

  @override
  void initState() {
    super.initState();
    _loadModelAndRunInference();
    _getUserIdFromPrefs();
  }

  Future<void> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
    });
  }

  Future<void> _loadModelAndRunInference() async {
    try {
      // Load both models from assets
      // _wheatInterpreter =
      //     await Interpreter.fromAsset('assets/models/wheat_classifier.tflite');
      _rustInterpreter =
          await Interpreter.fromAsset('assets/models/wheat_rust.tflite');

      setState(() {
        _isProcessing = true;
      });

      // final isWheat = await _checkIfWheat(widget.imageFile);

      // if (isWheat) {
      //   setState(() {
      //     _resultText = "Wheat detected! Analayzing for rust";
      //     _isProcessing = true;
      //   });

      // } else {
      //   setState(() {
      //     _resultText =
      //         "Not a wheat plant!\nPlease capture a clear image of wheat leaves.";
      //     _isProcessing = false;
      //   });
      // }
      await _runRustInference(widget.imageFile);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Future<bool> _checkIfWheat(File imageFile) async {
  //   // Load image bytes and decode
  //   final bytes = await imageFile.readAsBytes();
  //   img.Image? image = img.decodeImage(bytes);
  //   if (image == null) {
  //     throw Exception("Cannot decode image");
  //   }

  //   // Get model input size (e.g., [1, 224, 224, 3])
  //   final inputShape = _wheatInterpreter.getInputTensor(0).shape;
  //   final inputHeight = inputShape[1];
  //   final inputWidth = inputShape[2];
  //   final inputChannels = inputShape[3];

  //   // Resize image to model input size
  //   img.Image resizedImage =
  //       img.copyResize(image, width: inputWidth, height: inputHeight);

  //   // Normalize and convert image to input tensor (Float32List)
  //   // Assuming model expects float32 input normalized to [0,1]
  //   var input = Float32List(inputHeight * inputWidth * inputChannels);
  //   int pixelIndex = 0;
  //   for (int y = 0; y < inputHeight; y++) {
  //     for (int x = 0; x < inputWidth; x++) {
  //       int pixel = resizedImage.getPixel(x, y);
  //       // Extract RGB channels and normalize
  //       input[pixelIndex++] = (img.getRed(pixel)) / 255.0;
  //       input[pixelIndex++] = (img.getGreen(pixel)) / 255.0;
  //       input[pixelIndex++] = (img.getBlue(pixel)) / 255.0;
  //     }
  //   }

  //   // Prepare input tensor shape: [1, height, width, channels]
  //   var inputTensor =
  //       input.reshape([1, inputHeight, inputWidth, inputChannels]);

  //   // Prepare output buffer
  //   final outputShape = _wheatInterpreter.getOutputTensor(0).shape;
  //   debugPrint('Output shape: $outputShape');
  //   var output = List.generate(
  //     outputShape[0],
  //     (_) => List.filled(outputShape[1], 0.0),
  //   );

  //   // Run inference
  //   _wheatInterpreter.run(inputTensor, output);

  //   // Extract probabilities from output
  //   List<double> probabilities = output[0];

  //   // Find max probability and index
  //   double maxProb = probabilities.reduce((a, b) => a > b ? a : b);
  //   int maxIndex = probabilities.indexOf(maxProb);

  //   String predictedLabel = _wheatLabels[maxIndex];

  //   debugPrint('Wheat classifier: $predictedLabel, confidence: $maxProb');

  //   // You can adjust the threshold as needed
  //   return predictedLabel == "wheat" && maxProb > 0.8;
  // }

  Future<void> _runRustInference(File imageFile) async {
    // Load image bytes and decode
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception("Cannot decode image");
    }

    // Get input shape
    final inputShape = _rustInterpreter.getInputTensor(0).shape;
    final inputHeight = inputShape[1];
    final inputWidth = inputShape[2];
    final inputChannels = inputShape[3];

    // Resize and normalize
    img.Image resizedImage =
        img.copyResize(image, width: inputWidth, height: inputHeight);
    var input = Float32List(inputHeight * inputWidth * inputChannels);
    int pixelIndex = 0;
    for (int y = 0; y < inputHeight; y++) {
      for (int x = 0; x < inputWidth; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[pixelIndex++] = pixel.r / 255.0;
        input[pixelIndex++] = pixel.g / 255.0;
        input[pixelIndex++] = pixel.b / 255.0;
      }
    }
    var inputTensor =
        input.reshape([1, inputHeight, inputWidth, inputChannels]);

    // Prepare output
    final outputShape = _rustInterpreter.getOutputTensor(0).shape;
    var output =
        List.generate(outputShape[0], (_) => List.filled(outputShape[1], 0.0));

    // Run inference
    _rustInterpreter.run(inputTensor, output);

    // Analyze result
    List<double> probabilities = output[0];
    double maxProb = probabilities.reduce((a, b) => a > b ? a : b);
    int maxIndex = probabilities.indexOf(maxProb);

    setState(() {
      _predictedLabel = _rustLabels[maxIndex];
      _confidence = maxProb;
      _isProcessing = false;
    });
  }

  @override
  void dispose() {
    _wheatInterpreter.close();
    _rustInterpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diagnosis = _diagnosisInfo[_predictedLabel] ?? {};
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnosis Page"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(18),
            //   child: Image.file(
            //     widget.imageFile,
            //     height: 180,
            //     width: double.infinity,
            //     fit: BoxFit.cover,
            //   ),
            // ),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: _isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Diagnosis",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$_predictedLabel (${(_confidence * 100).toStringAsFixed(2)}%)",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (_predictedLabel != "Healthy")
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                const Row(
                                  children: [
                                    Icon(Icons.sick, size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      "Symptoms",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ...List.generate(
                                  (diagnosis["symptoms"] as List).length,
                                  (i) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, bottom: 2),
                                    child: Text(
                                      "• ${diagnosis["symptoms"][i]}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Row(
                                  children: [
                                    Icon(Icons.medical_services, size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      "Treatment Recommendation",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ...List.generate(
                                  (diagnosis["treatment"] as List).length,
                                  (i) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, bottom: 2),
                                    child: Text(
                                      "• ${diagnosis["treatment"][i]}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                "No disease detected. Your plant appears healthy.",
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 18),
            _buildFeedbackButton(
              icon: Icons.feedback_outlined,
              text: "Is our AI accurate?",
              subText:
                  "Click here to give us feedback on how we improve our application.",
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => FeedbackDialog(
                          onSubmit: (rating, comment, aiAccuracy) async {
                            await apiService.sendFeedbackToApi(
                                rating: rating,
                                comment: comment,
                                aiAccuracy: aiAccuracy);
                          },
                        )).then((result) {
                  if (result == true) {
                    // Now you can safely use context to show snackbar or navigate
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback submitted!')),
                    );
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/home', (route) => false);
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            _buildFeedbackButton(
              icon: Icons.help_outline,
              text: "Can't find the right result?",
              subText: "Click here to ask the community for help.",
              onTap: () async {
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not logged in!')),
                  );
                  return;
                }
                final XFile xfile = XFile(widget.imageFile.path);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePostPage(
                      userId: userId!,
                      initialImage: xfile,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackButton({
    required IconData icon,
    required String text,
    required String subText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFD8F5E3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.green[900]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subText,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
