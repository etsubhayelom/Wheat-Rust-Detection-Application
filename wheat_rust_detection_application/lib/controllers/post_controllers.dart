import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/api_services.dart';
import 'package:wheat_rust_detection_application/models/post_model.dart';

class PostController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  List<Post> get posts => _posts;

  Future<Post?> createPost({
    required String userId,
    String? text,
    List<File>? images,
  }) async {
    try {
      final response = await _apiService.createPost(
        userId,
        text: text,
        image: images,
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
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

  Future<void> createComment(String postId, String comment) async {
    try {
      final response = await _apiService.createComment(postId, comment);
      if (response.statusCode == 201) {
        debugPrint('Comment created successfully');
      } else {
        debugPrint('Failed to create comment: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating comment: $e');
    }
  }

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _apiService.fetchPosts();
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
    try {
      final response = await _apiService.fetchUserPosts(userId);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return (jsonData as List).map((post) => Post.fromJson(post)).toList();
      } else {
        throw Exception('Failed to fetch user posts');
      }
    } catch (e) {
      debugPrint('Error fetching user posts: $e');
      throw Exception('Error fetching user posts');
    }
  }
}
