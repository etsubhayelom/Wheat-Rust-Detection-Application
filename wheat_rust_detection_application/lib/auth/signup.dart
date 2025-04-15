import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheat_rust_detection_application/auth/login.dart';
import 'package:wheat_rust_detection_application/constants.dart';

import 'package:wheat_rust_detection_application/controllers/signup_controller.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  static String route = 'signup-page';

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final SignupController signupController = Get.put(SignupController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();

  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupController>(builder: (_) {
      if (signupController.isError) {
        return Text(signupController.errorMessage ?? '');
      } else if (signupController.isLoading) {
        return const CircularProgressIndicator();
      } else {
        return Scaffold(
          body: SafeArea(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  // App Name
                  Text(
                    "Sende",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primary),
                  ),
                  const SizedBox(height: 10),
                  // Login Title
                  Text(
                    "Register",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.secondary),
                  ),
                  const SizedBox(height: 30),
                  //username field
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "User Name",
                      hintText: "Emma Foster",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  //email field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Enter Email",
                      hintText: "Plant@gmail.com",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Role Dropdown Field
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Choose Your Role",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    value: selectedRole,
                    items: ["User", "Farmer", "Researcher"]
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "********",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.remove_red_eye_outlined),
                        onPressed:
                            () {}, // Add functionality for toggling password visibility
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _password2Controller,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "********",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.remove_red_eye_outlined),
                        onPressed:
                            () {}, // Add functionality for toggling password visibility
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  const SizedBox(height: 30),
                  //signup button
                  ElevatedButton(
                    onPressed: () {
                      if (_passwordController.text ==
                          _password2Controller.text) {
                        signupController.registerUser(
                          _emailController.text,
                          _nameController.text,
                          _passwordController.text,
                        );
                      } else {
                        // Handle password mismatch
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primary,
                      minimumSize:
                          const Size(double.infinity, 50), // Full-width button
                    ),
                    child: const Text("Register",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),

                  const SizedBox(height: 20),

                  //login link
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Log in",
                          style: TextStyle(
                              color: AppConstants.secondary,
                              fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(() =>
                                  const LoginPage()); // Navigate to SignUpPage
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        );
      }
    });
  }
}
