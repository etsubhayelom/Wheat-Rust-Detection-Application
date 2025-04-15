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

  Future<void> registerUser(String name, String email, String password) async {
    isLoading = true;
    update();

    try {
      final response = await _apiService.signup(email, name, password);

      if (response.statusCode == 201) {
        debugPrint('User registered successfully');
        final responseData = jsonDecode(response.body);
        final token =
            responseData['token']; // Assuming the token is in the 'token' field

        // Store the token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        debugPrint('Token stored successfully');
        Get.to(() => const HomePage());
        // Handle successful registration
      } else {
        debugPrint('Signup failed: ${response.statusCode}');
        isError = true;
        errorMessage = 'Registration failed';
      }
    } catch (e) {
      debugPrint('Error registering user: $e');
      isError = true;
      errorMessage = 'An error occurred';
    } finally {
      isLoading = false;
      update();
    }
  }
}
