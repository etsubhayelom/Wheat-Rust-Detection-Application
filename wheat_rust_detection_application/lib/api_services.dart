import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String _baseUrl = 'https://wheat-rust-detection-backend.onrender.com';

  Future<http.Response> signup(
      String name, String email, String password) async {
    final url = Uri.parse('$_baseUrl/signup/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "password2": password,
      }),
    );

    log('Signup Response: Status Code = ${response.statusCode}, Body = ${response.body}'); // Use log instead of print

    return response;
  }

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    // Print the response details
    log('Login Response: Status Code = ${response.statusCode}, Body = ${response.body}');
    return response;
  }

  Future<http.Response> createPost(
    String userId, {
    String? text,
    List<File>? image,
  }) async {
    final url = Uri.parse(
        '$_baseUrl/community/posts/create/'); // Adjust the URL as per your API
    var request = http.MultipartRequest('POST', url);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    request.fields['user'] = userId;

    if (text != null) {
      request.fields['text'] = text;
    }

    if (image != null && image.isNotEmpty) {
      for (var imgFile in image) {
        String mimeType = lookupMimeType(imgFile.path) ?? 'image/jpeg';
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imgFile.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
    }

    if (authToken != null) {
      request.headers['Authorization'] = 'Bearer $authToken';
    } else {
      throw Exception('Authentication token not found');
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      log('Create Post Response: Status Code = ${response.statusCode}, Body = ${response.body}'); // Log the create post response
      return response;
    } catch (e) {
      debugPrint('Error sending request: $e');
      throw Exception('Failed to create post');
    }
  }

  Future<http.Response> likePost(String postID) async {
    final url = Uri.parse('$_baseUrl/community/posts/$postID/like/');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $authToken', // Include the token
      },
    );

    log('Like Post Response: Status Code = ${response.statusCode}, Body = ${response.body}');
    return response;
  }

  // Method to dislike a post
  Future<http.Response> dislikePost(String postId) async {
    final url = Uri.parse('$_baseUrl/community/posts/$postId/dislike/');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $authToken', // Include the token
      },
    );

    log('Dislike Post Response: Status Code = ${response.statusCode}, Body = ${response.body}');

    return response;
  }

  // Method to create a comment
  Future<http.Response> createComment(String postId, String comment) async {
    final url = Uri.parse('$_baseUrl/community/posts/$postId/comment/');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken', // Include the token
      },
      body: jsonEncode({
        "text": comment, // Changed "comment" to "text" to match the API
      }),
    );

    log('Create Comment Response: Status Code = ${response.statusCode}, Body = ${response.body}');

    return response;
  }

  // Method to fetch posts (you can implement this as needed)
  Future<http.Response> fetchPosts() async {
    final url = Uri.parse('$_baseUrl/community/posts/');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken', // Include the token
      },
    );

    log('Fetch Posts Response: Status Code = ${response.statusCode}, Body = ${response.body}');

    return response;
  }

  Future<http.Response> fetchUserPosts(String userId) async {
    final url = Uri.parse('$_baseUrl/community/posts/?user=$userId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    log('Fetch User Posts Response: Status Code = ${response.statusCode}, Body = ${response.body}');

    return response;
  }
}
