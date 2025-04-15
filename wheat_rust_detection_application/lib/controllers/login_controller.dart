import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheat_rust_detection_application/api_services.dart';
import 'package:wheat_rust_detection_application/views/home_page_widgets/home_page.dart';

class LoginController extends GetxController {
  bool isLoading = false;
  bool isError = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> loginUser(String email, String password) async {
    isLoading = true;
    update();

    try {
      final response = await _apiService.login(email, password);

      if (response.statusCode == 200) {
        debugPrint('User logged in successfully');
        final responseData = jsonDecode(response.body);
        // Correctly access the access token
        final accessToken = responseData['access_token']; // Fix here
        final refreshToken = responseData[
            'refresh_token']; // Optional, if needed // Assuming the token is in the 'token' field
        final userId = responseData['user']['id'].toString();
        final userName = responseData['user']['name'];
        final userEmail = responseData['user']['email'];

        debugPrint('Access token and user ID stored successfully');
        // Store the token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        debugPrint(prefs.getString('auth_token'));
        await prefs.setString('auth_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        await prefs.setString('user_id', userId);
        await prefs.setString('user_name', userName);
        await prefs.setString('user_email', userEmail);

        debugPrint('Token stored successfully');

        Get.offAll(() => const HomePage());
        // Handle successful login (e.g., save token, navigate to home screen)
      } else {
        debugPrint('Login failed: ${response.statusCode}');
        isError = true;
        errorMessage = 'Login failed';
        Get.snackbar(
          'Login Error',
          'Failed to login user',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3), // Adjust as needed
        );
      }
    } catch (e) {
      debugPrint('Error logging in user: $e');
      isError = true;
      errorMessage = 'An error occurred';
      Get.snackbar(
        'Login Error',
        'An error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3), // Adjust as needed
      );
    } finally {
      isLoading = false;
      update();
    }
  }
}
