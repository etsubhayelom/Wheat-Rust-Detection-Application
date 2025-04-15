import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';
import 'package:wheat_rust_detection_application/views/splash.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PostController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (context, child) {
        return const GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My App',
          home: SplashScreen(), // Replace with your home screen
        );
      },
    );
  }
}
