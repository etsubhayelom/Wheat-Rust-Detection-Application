import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheat_rust_detection_application/services/api_services.dart';
import 'package:wheat_rust_detection_application/views/home_page_widgets/home_page.dart';

class LoginController extends GetxController {
  bool isLoading = false;
  bool isError = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  Future<bool> loginUser(
      String identifier, String password, bool isEmail) async {
    isLoading = true;
    update();

    try {
      final response = await _apiService.login(identifier, password, isEmail);

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
        final userRole = responseData['user']['role'] ?? 'Other';

        // Store the token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('auth_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        await prefs.setString('user_id', userId);
        await prefs.setString('user_name', userName);
        await prefs.setString('user_email', userEmail);
        await prefs.setString('role', userRole);

        debugPrint('Token stored successfully');

        Get.offAll(() => const HomePage());

        isLoading = false;
        update();

        return true;
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
        isLoading = false;
        update();

        return false;
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

      isLoading = false;
      update();

      return false;
    } finally {
      isLoading = false;
      update();
    }
  }
}
