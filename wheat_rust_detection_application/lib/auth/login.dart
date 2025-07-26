import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/auth/signup.dart';
import 'package:wheat_rust_detection_application/constants.dart';
import 'package:wheat_rust_detection_application/controllers/login_controller.dart';
import 'package:wheat_rust_detection_application/utils/custom_snack_bar.dart';
import 'package:wheat_rust_detection_application/views/home_page_widgets/home_page.dart';

class LoginPage extends StatefulWidget {
  static String route = 'login-page';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController loginController = Get.put(LoginController());
  bool isEmailMode = true;

  final _identifierController = TextEditingController();
  final _pwdController = TextEditingController();

  bool _obscurePassword = true;

  void toggleInputMode() {
    setState(() {
      isEmailMode = !isEmailMode;
      _identifierController.clear();
    });
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  void login() async {
    final identifier = _identifierController.text.trim();
    final password = _pwdController.text;

    if (identifier.isEmpty || password.isEmpty) {
      CustomSnackBar.show(
        context,
        title: 'Error',
        message: 'Please fill in all fields',
        isError: true,
      );
      return;
    }

    if (isEmailMode && !isValidEmail(identifier)) {
      CustomSnackBar.show(
        context,
        title: 'Error',
        message: 'Please enter a valid email address',
        isError: true,
      );
      return;
    }

    bool success =
        await loginController.loginUser(identifier, password, isEmailMode);

    if (!success) {
      CustomSnackBar.show(
        context,
        title: 'Login Failed',
        message: 'Incorrect email/phone or password',
        isError: true,
      );
    }
  }

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
                      fontFamily: 'PlusJakartaSans',
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: toggleInputMode,
                      child: Text(
                        isEmailMode ? 'Switch to Phone' : 'Switch to Email',
                        style: TextStyle(color: AppConstants.primary),
                      ),
                    ),
                  ],
                ),

                // Email Field
                TextField(
                  controller: _identifierController,
                  keyboardType: isEmailMode
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: isEmailMode ? 'Email' : 'Phone Number',
                    prefixIcon: Icon(isEmailMode
                        ? Icons.email_outlined
                        : Icons.phone_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _pwdController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "********",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.remove_red_eye_outlined
                          : Icons.remove_red_eye),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      }, // Add functionality for toggling password visibility
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
                  onPressed: controller.isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primary,
                    minimumSize:
                        const Size(double.infinity, 50), // Full-width button
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text("Login",
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
