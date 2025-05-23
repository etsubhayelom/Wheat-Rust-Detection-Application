import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheat_rust_detection_application/services/api_services.dart';
import 'package:wheat_rust_detection_application/views/home_page_widgets/home_page.dart';

class SignupController extends GetxController {
  bool isLoading = false;
  bool isError = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> registerUser(String name, String email, String password,
      String role, String phoneNumber) async {
    isLoading = true;
    update();

    try {
      final response =
          await _apiService.signup(name, email, password, role, phoneNumber);

      if (response.statusCode == 201) {
        debugPrint('User registered successfully');
        final responseData = jsonDecode(response.body);

        final accessToken = responseData['access_token'];
        final refreshToken = responseData['refresh_token'];
        final user = responseData['user'];

        // Store the token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('user_id', user['id'].toString());
        await prefs.setString('name', user['name'] ?? '');
        await prefs.setString('email', user['email'] ?? '');
        await prefs.setString('role', user['role'] ?? 'Other');
        await prefs.setString('auth_token', accessToken ?? '');
        await prefs.setString('refresh_token', refreshToken ?? '');

        debugPrint('Token stored successfully');
        Get.offAll(() => const HomePage());
        // Handle successful registration
      } else {
        debugPrint('Signup failed: ${response.statusCode}');
        isError = true;
        errorMessage =
            jsonDecode(response.body)['detail'] ?? 'Registration failed';

        Get.snackbar(
          'Signup Error',
          errorMessage!,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('Error registering user: $e');
      isError = true;
      errorMessage = 'An error occurred';
      Get.snackbar(
        'Signup Error',
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
