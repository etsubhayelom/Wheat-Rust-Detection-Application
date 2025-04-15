import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';
import 'package:wheat_rust_detection_application/views/home_page_widgets/post_card.dart';
import 'package:wheat_rust_detection_application/views/home_page_widgets/post_details.dart';
import 'package:wheat_rust_detection_application/views/notifications.dart';
import 'package:wheat_rust_detection_application/views/settings.dart';

import '../../constants.dart';
import '../posting_page.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  String _userId = '';

  @override
  void initState() {
    super.initState();

    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id') ??
          ''; // Load the user ID, default to empty string if not found
    });

    Provider.of<PostController>(context, listen: false).fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'Sende',
          style: TextStyle(
            fontSize: 30,
            color: AppConstants.secondary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15), // Soft grey background
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: Colors.black,
              onPressed: () => Get.to(() => const NotificationsPage()),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15), // Soft grey background
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              color: Colors.black,
              onPressed: () => Get.to(() => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 10, top: 10),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(color: Colors.grey, width: 0.5),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              SizedBox(
                                width: 200.w,
                                child: Text(
                                  'Search in Community',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                ],
              ),
            ),
            // Example of a reusable card widget
            Consumer<PostController>(
              builder: (context, postController, child) {
                if (postController.posts.isEmpty) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Or a message like "No posts yet"
                } else {
                  return Column(
                    children: postController.posts.map((post) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailsPage(),
                            ),
                          );
                        },
                        child: PostCard(
                          post: post,
                          postController: postController,
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newPost = await Get.to(() => CreatePostPage(userId: _userId));
          if (newPost != null && mounted) {
            Provider.of<PostController>(context, listen: false).fetchPosts();
          }
        },
        label: const Text(
          'Ask Community',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        icon: const Icon(
          Icons.edit_outlined,
          color: Colors.white,
          size: 30,
        ),
        backgroundColor: AppConstants.yellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Adjust the value as needed
        ),
      ),
    );
  }
}
