import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheat_rust_detection_application/services/api_services.dart';
import 'package:wheat_rust_detection_application/models/post_model.dart';
import 'package:wheat_rust_detection_application/services/cloudinary.dart';

class PostController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  List<Post> get posts => _posts;
  List<Post> _savedPosts = [];
  List<Post> get savedPosts => _savedPosts;
  bool isloading = false;

  Future<Post?> createPost({
    required String userId,
    String? text,
    List<File>? images,
    File? audio,
    File? file,
    String? postType,
    String? title,
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

      String? imageUrl;
      if (images != null && images.isNotEmpty) {
        imageUrl = await uploadToCloudinary(images.first, "image");
        if (imageUrl == null) {
          debugPrint('Image upload failed');
          return null; // or show error to user
        }
      }
      String? audioUrl;
      if (audio != null) {
        audioUrl = await uploadToCloudinary(audio, "auto");
        if (audioUrl == null) {
          debugPrint('Audio upload failed');
          return null; // or show error to user
        }
      }

      String? fileUrl;
      if (file != null) {
        fileUrl = await uploadToCloudinary(file, "raw");
      }
      final response = await _apiService.createPostWithImageUrls(
        userId,
        text: text,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        fileUrl: fileUrl,
        postType: postType,
        title: title,
        accessToken: accessToken,
      );
      debugPrint('Uploaded audio Url: $audioUrl');

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        fetchPosts();
        return Post.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        final refreshResponse = await _apiService.refreshToken(refreshToken);
        if (refreshResponse.statusCode == 200) {
          final newAccessToken = jsonDecode(refreshResponse.body)['access'];
          await prefs.setString('auth_token', newAccessToken);

          // Retry with new access token
          final response = await _apiService.createPostWithImageUrls(
            userId,
            text: text,
            imageUrl: imageUrl,
            audioUrl: audioUrl,
            fileUrl: fileUrl,
            postType: postType,
            title: title,
            accessToken: newAccessToken,
          );

          if (response.statusCode == 201) {
            final jsonData = jsonDecode(response.body);
            fetchPosts();
            return Post.fromJson(jsonData);
          }
        }
      }

      debugPrint('Failed to create post: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return null;
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
    isloading = true;
    notifyListeners();
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
    } finally {
      isloading = false;
    }
  }

  Future<List<Post>> fetchUserPosts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      if (userId == null) throw Exception('User not logged in');

      final List<Post> posts = await _apiService.fetchUserPosts(userId);
      return posts;
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
    required String title,
    File? file,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('auth_token');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _apiService.postArticle(
          userId: userId,
          text: text,
          title: title,
          file: file,
          accessToken: accessToken);
      final respStr = await response.stream.bytesToString();
      debugPrint('POST ARTICLE RESPONSE: ${response.statusCode} $respStr');

      if (response.statusCode == 201) {
        fetchPosts(); // Refresh posts
      } else {
        throw Exception('Failed to post article:$respStr');
      }
    } catch (e) {
      debugPrint('Error posting article: $e');
      rethrow;
    }
  }

  Future<bool> savePost(String postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('auth_token');
    if (accessToken == null) return false;

    final response = await _apiService.savePost(postId, accessToken);
    debugPrint('Response: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<bool> unsavePost(String postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('auth_token');
    if (accessToken == null) return false;

    final response = await _apiService.unsavePost(postId, accessToken);
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }
    return false;
  }

  Future<void> fetchSavedPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('auth_token');
    String? userId = prefs.getString('user_id');
    if (accessToken == null || userId == null) return;

    final response = await _apiService.fetchSavedPosts(userId, accessToken);
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      _savedPosts = jsonData.map((post) => Post.fromJson(post)).toList();
      notifyListeners();
    } else {
      debugPrint('Failed to fetch saved posts: ${response.statusCode}');
    }
  }

  Future<bool> deletePost(String postId) async {
    final response = await _apiService.deletePost(postId);
    if (response.statusCode == 204 || response.statusCode == 200) {
      _posts.removeWhere((post) => post.id.toString() == postId);
      notifyListeners();
      return true;
    }
    return false;
  }
}
