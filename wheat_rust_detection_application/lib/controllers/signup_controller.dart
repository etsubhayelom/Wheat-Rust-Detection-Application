import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheat_rust_detection_application/api_services.dart';
import 'package:wheat_rust_detection_application/views/home_page_widgets/home_page.dart';

class SignupController extends GetxController {
  bool isLoading = false;
  bool isError = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> registerUser(
      String name, String email, String password, String role) async {
    isLoading = true;
    update();

    try {
      final response = await _apiService.signup(name, email, password);

      if (response.statusCode == 201) {
        debugPrint('User registered successfully');
        final responseData = jsonDecode(response.body);

        // Store the token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('user_id', responseData['id'].toString());
        await prefs.setString('name', responseData['name']);
        await prefs.setString('email', responseData['email']);
        await prefs.setString('role', responseData['role'] ?? 'Other');

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
