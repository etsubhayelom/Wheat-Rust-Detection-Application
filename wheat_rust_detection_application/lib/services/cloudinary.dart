import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

Future<String?> uploadToCloudinary(File file, String resourceType) async {
  const cloudName = 'dliqfcd2u';
  const uploadPreset = 'sende_application';

  final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');
  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath('file', file.path));

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    final data = jsonDecode(responseBody);
    return data['secure_url'] as String;
  } else {
    debugPrint('Cloudinary upload failed: $responseBody');
    return null;
  }
}

// Future<String?> uploadAudioToCloudinary(
//     File audioFile, String resourceType) async {
//   const cloudName = 'dliqfcd2u';
//   const uploadPreset = 'sende_application';

//   final url =
//       Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');
//   final request = http.MultipartRequest('POST', url)
//     ..fields['upload_preset'] = uploadPreset
//     ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

//   final response = await request.send();
//   final responseBody = await response.stream.bytesToString();

//   if (response.statusCode == 200) {
//     final data = jsonDecode(responseBody);
//     return data['secure_url'] as String;
//   } else {
//     debugPrint('Cloudinary upload failed: $responseBody');
//     return null;
//   }
// }
