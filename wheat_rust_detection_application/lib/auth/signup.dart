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

  String? _role;

  final List<Map<String, String>> roleOptions = [
    {"value": "admin", "label": "Admin"},
    {"value": "farmer", "label": "Farmer"},
    {"value": "researcher", "label": "Agricultural Researcher"},
    {"value": "expert", "label": "Agricultural Expert"},
  ];

  @override
  Widget build(BuildContext context) {
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
                    fontFamily: 'PlusJakartaSans',
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
              DropdownButtonFormField(
                value: _role,
                decoration: InputDecoration(
                  labelText: "Choose Your Role",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                items: roleOptions
                    .map((role) => DropdownMenuItem(
                          value: role["value"],
                          child: Text(role["label"]!),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _role = value.toString();
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
              GetBuilder<SignupController>(builder: (controller) {
                return ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () {
                          if (_passwordController.text ==
                              _password2Controller.text) {
                            if (_role != null) {
                              controller.registerUser(
                                _nameController.text,
                                _emailController.text,
                                _passwordController.text,
                                _role!,
                              );
                            } else {
                              Get.snackbar(
                                'Signup Error',
                                'Please select a role.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                              );
                            }
                          } else {
                            Get.snackbar(
                              'Signup Error',
                              'Passwords do not match.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 3),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primary,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Register",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                );
              }),

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
}
