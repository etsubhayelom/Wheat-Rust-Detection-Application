import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheat_rust_detection_application/services/api_services.dart';
import 'package:wheat_rust_detection_application/models/post_model.dart';

class PostController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  List<Post> get posts => _posts;

  Future<Post?> createPost({
    required String userId,
    String? text,
    List<File>? images,
    File? audio,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('auth_token');
      String? refreshToken = prefs.getString('refresh_token');
      if (accessToken == null || refreshToken == null) {
        // Handle case where tokens are not available
        debugPrint('Tokens not found. Please log in again.');
        return null;
      }
      http.Response response = await _apiService.createPost(
        userId,
        text: text,
        image: images,
        audio: audio,
        accessToken: accessToken,
      );

      debugPrint('API Response status: ${response.statusCode}');
      debugPrint('API Response body: ${response.body}');
      if (response.statusCode == 401) {
        // Token might be expired, try to refresh
        debugPrint('Access token expired, attempting to refresh');
        final refreshResponse = await _apiService.refreshToken(refreshToken);

        debugPrint(
            'Refresh token response status: ${refreshResponse.statusCode}');
        debugPrint('Refresh token response body: ${refreshResponse.body}');

        if (refreshResponse.statusCode == 200) {
          final newAccessToken = jsonDecode(refreshResponse.body)['access'];
          await prefs.setString('auth_token', newAccessToken);
          debugPrint('Access token refreshed successfully');

          // Retry the original request with the new access token
          response = await _apiService.createPost(
            userId,
            text: text,
            image: images,
            audio: audio,
            accessToken: newAccessToken, // Use new access token
          );

          debugPrint('Retried API Response status: ${response.statusCode}');
          debugPrint('Retried API Response body: ${response.body}');
        } else {
          // Refresh failed, redirect user to login
          debugPrint('Failed to refresh token: ${refreshResponse.statusCode}');
          // Redirect to login page
          return null;
        }
      }

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        fetchPosts();
        return Post.fromJson(jsonData);
      } else {
        debugPrint('Failed to create post: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      return null;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      final response = await _apiService.likePost(postId);
      if (response.statusCode == 200) {
        debugPrint('Post liked successfully');
      } else {
        debugPrint('Failed to like post: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error liking post: $e');
    }
  }

  Future<void> dislikePost(String postId) async {
    try {
      final response = await _apiService.dislikePost(postId);
      if (response.statusCode == 200) {
        debugPrint('Post disliked successfully');
      } else {
        debugPrint('Failed to dislike post: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error disliking post: $e');
    }
  }

  Future<Comment?> createComment(
      {required String postId, required String comment}) async {
    try {
      final response = await _apiService.createComment(postId, comment);
      if (response.statusCode == 201) {
        debugPrint('Comment created successfully');
        fetchPosts();
        final jsonData = jsonDecode(response.body);
        return Comment.fromJson(jsonData);
      } else {
        debugPrint('Failed to create comment: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating comment: $e');
      return null;
    }
  }

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _apiService.fetchPosts();
      debugPrint('post response:{$response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        _posts = jsonData.map((post) => Post.fromJson(post)).toList();
        notifyListeners(); // Notify listeners about the change in data
        return _posts;
      } else {
        throw Exception('Failed to fetch posts');
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      throw Exception('Error fetching posts');
    }
  }

  Future<List<Post>> fetchUserPosts(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    try {
      final response = await _apiService.fetchUserPosts(userId!);
      debugPrint('user posts: {$response.body}');
      return response;
    } catch (e) {
      debugPrint('Error fetching user posts: $e');
      throw Exception('Error fetching user posts');
    }
  }

  Future<List<Comment>> fetchComments({required String postId}) async {
    try {
      final response = await _apiService.fetchPostComments(
          postId); // You need to implement this in ApiService
      debugPrint('Comments: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((c) => Comment.fromJson(c)).toList();
      } else {
        throw Exception('Failed to fetch comments');
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      throw Exception('Error fetching comments');
    }
  }

  // In post_controllers.dart

  Future<void> createArticle({
    required String userId,
    required String text,
    File? file,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('auth_token');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _apiService.postArticle(
          userId: userId, text: text, file: file, accessToken: accessToken);
      debugPrint('response of articles:$response');

      if (response.statusCode == 201) {
        fetchPosts(); // Refresh posts
      } else {
        final respStr = await response.stream.bytesToString();
        debugPrint('POST ARTICLE RESPONSE: ${response.statusCode} $respStr');
        throw Exception('Failed to post article:$respStr');
      }
    } catch (e) {
      debugPrint('Error posting article: $e');
      rethrow;
    }
  }
}
