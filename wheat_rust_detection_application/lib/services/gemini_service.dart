import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiKey = 'AIzaSyDxkgLKDFUMGghXvYOjiQlR19fobl4H0s8';
  final String _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=';

  Future<bool> isWheatRelated(String userInput) async {
    final response = await http.post(
      Uri.parse("$_url$_apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Say only 'yes' or 'no': Is this text about wheat or wheat-related agriculture? \"$userInput\""
              }
            ]
          }
        ]
      }),
    );
    debugPrint('Gemini response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['candidates'][0]['content']['parts'][0]['text'];
      debugPrint('Gemini response: $content');

      return content.toLowerCase().contains("yes");
    } else {
      debugPrint('Gemini API Error: ${response.statusCode}');
      debugPrint(response.body); // << Important to log this
      throw Exception('Gemini API Error: ${response.statusCode}');
    }
  }
}
