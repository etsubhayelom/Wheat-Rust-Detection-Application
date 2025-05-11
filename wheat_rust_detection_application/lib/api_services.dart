import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheat_rust_detection_application/models/article_model.dart';
import 'package:wheat_rust_detection_application/models/post_model.dart';

class ApiService {
  final String _baseUrl = 'https://wheat-rust-detection-backend.onrender.com';

  Future<http.Response> signup(
      String name, String email, String password, String role) async {
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
        "role": role,
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
    required String accessToken,
  }) async {
    final url = Uri.parse(
        '$_baseUrl/community/posts/create/'); // Adjust the URL as per your API
    var request = http.MultipartRequest('POST', url);

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

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['user'] = userId;

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
        "text": comment,
        "post": postId,
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

  Future<List<Post>> fetchUserPosts(String userId) async {
    final url =
        Uri.parse('$_baseUrl/community/posts/?user=$userId&post_type=question');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user questions');
    }
  }

  Future<http.Response> refreshToken(String refreshToken) async {
    final url = Uri.parse(
        '$_baseUrl/token/refresh/'); // Or whatever your refresh endpoint is
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    return response;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$_baseUrl/users/'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);
      String? userEmail = prefs.getString('email');

      for (var user in users) {
        if (user['email'] == userEmail) {
          return user;
        }
      }
      throw Exception('User not found');
    } else {
      throw Exception('Failed to load user data: ${response.statusCode}');
    }
  }

  Future<http.Response> uploadProofOfQualification(
      File pdfFile, String role) async {
    final url = Uri.parse('$_baseUrl/verify/request/');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    var request = http.MultipartRequest('POST', url);

    request.fields['role'] = role;

    // Attach the PDF file
    request.files.add(
      await http.MultipartFile.fromPath(
        'certificate', // Use the field name expected by your backend
        pdfFile.path,
        contentType: MediaType('application', 'pdf'),
      ),
    );

    // Add authorization if needed
    if (authToken != null) {
      request.headers['Authorization'] = 'Bearer $authToken';
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      log('Upload Proof Response: Status Code = ${response.statusCode}, Body = ${response.body}');
      return response;
    } catch (e) {
      debugPrint('Error uploading proof: $e');
      throw Exception('Failed to upload proof');
    }
  }

  Future<http.Response> updateProfilePicture(File imageFile) async {
    final url =
        Uri.parse('$_baseUrl/users/me/'); // Update with your actual endpoint
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    var request = http.MultipartRequest('PATCH', url);

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $authToken';

    // Add image file
    request.files.add(await http.MultipartFile.fromPath(
      'profile_image', // Should match your Django model field name
      imageFile.path,
      contentType: MediaType('image', 'jpeg'), // Adjust if needed
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Update local storage if successful
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        await prefs.setString(
            'profile_image_url', jsonResponse['profile_image']);
      }

      return response;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  Future<Map<String, dynamic>> getVerificationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      return {'is_approved': false};
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/verification-status/$userId/'),
        // headers: await getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        debugPrint("API response: ${response.body}");
        return jsonDecode(response.body);
      }
      return {'is_approved': false};
    } catch (e) {
      debugPrint("Error fetching verification status: $e");
      return {'is_approved': false};
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    final url = Uri.parse('$_baseUrl/profile/');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    log('Fetch User Profile Response: Status Code = ${response.statusCode}, Body = ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user profile: ${response.statusCode}');
    }
  }

  Future<http.Response> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    required String role,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    final url = Uri.parse(
        'https://wheat-rust-detection-backend.onrender.com/profile/update/');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'role': role,
      }),
    );
    return response;
  }

  Future<http.Response> fetchPostComments(String postId) async {
    final url = Uri.parse('$_baseUrl/posts/$postId/comments/');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );
  }

  Future<http.Response> fetchNotificationsFromApi() async {
    final url = Uri.parse('$_baseUrl/notifications/');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');
    return await http.get(
      url,
      headers: {'Authorization': 'Bearer $authToken'},
    );
  }

  Future<http.Response> markNotificationAsRead(int notificationId) async {
    final url = Uri.parse('$_baseUrl/notifications/$notificationId/read/');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');
    return await http.post(
      url,
      headers: {'Authorization': 'Bearer $authToken'},
    );
  }

  Future<List<Post>> fetchUserArticles(String userId) async {
    final response = await http.get(
        Uri.parse('$_baseUrl/community/posts/?user=$userId&post_type=article'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user articles');
    }
  }

  Future<void> postArticle({
    required String userId,
    required String title,
    required String text,
    String? imagePath,
    String? audioPath,
  }) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('$_baseUrl/community/posts/create'));
    request.fields['user'] = userId;
    request.fields['post_type'] = 'article';
    request.fields['title'] = title;
    request.fields['text'] = text;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }
    if (audioPath != null) {
      request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
    }

    final response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Failed to post article');
    }
  }
}
