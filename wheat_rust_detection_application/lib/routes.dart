import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/auth/login.dart';
import 'package:wheat_rust_detection_application/auth/signup.dart';
import 'package:wheat_rust_detection_application/views/home_page_widgets/home_page.dart';
import 'package:wheat_rust_detection_application/views/splash.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    SplashScreen.route: (context) => const SplashScreen(),
    LoginPage.route: (context) => const LoginPage(),
    SignupPage.route: (context) => const SignupPage(),
    HomePage.route: (context) => const HomePage(),
  };
}
