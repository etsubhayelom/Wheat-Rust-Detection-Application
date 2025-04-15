import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/auth/signup.dart';
import 'package:wheat_rust_detection_application/constants.dart';
import 'package:wheat_rust_detection_application/controllers/login_controller.dart';
import 'package:wheat_rust_detection_application/views/home_page_widgets/home_page.dart';

class LoginPage extends StatefulWidget {
  static var route;

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController loginController = Get.put(LoginController());
  final _emailController = TextEditingController();
  final _pwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (controller) {
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
                  "Login",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.secondary),
                ),
                const SizedBox(height: 30),
                // Email Field
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

                // Password Field
                TextField(
                  controller: _pwdController,
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

                const SizedBox(height: 10),
                //remember me and forgot password row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (value) {}),
                        const Text("Remember me"),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const HomePage());
                      },
                      child: const Text("Forgot Password?",
                          style: TextStyle(color: Colors.blue)),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                //login button
                ElevatedButton(
                  onPressed: () {
                    loginController.loginUser(
                      _emailController.text,
                      _pwdController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primary,
                    minimumSize:
                        const Size(double.infinity, 50), // Full-width button
                  ),
                  child: const Text("Login",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
                const SizedBox(height: 20),

                //signup link
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                            color: AppConstants.secondary,
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(() =>
                                const SignupPage()); // Navigate to SignUpPage
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                //or divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('or'),
                    ),
                    Expanded(child: Divider()),
                  ],
                )
              ],
            ),
          ),
        )),
      );
    });
  }
}
