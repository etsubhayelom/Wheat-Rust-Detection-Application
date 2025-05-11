import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wheat_rust_detection_application/api_services.dart';
import 'package:wheat_rust_detection_application/constants.dart';
import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';
import 'package:wheat_rust_detection_application/controllers/profile_controller.dart';

import 'package:wheat_rust_detection_application/views/edit_profile.dart';
import 'package:wheat_rust_detection_application/views/posting_page.dart';

import '../models/post_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final ProfileController _profileController = Get.put(ProfileController());
  Map<String, dynamic>? _userProfile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingProfile = true;
  String? _errorProfile;
  List<Post> _userPosts = [];
  List<Post> _userArticles = [];
  bool _isLoadingPosts = true;
  bool _isLoadingArticles = true;
  final PostController _postController = PostController();
  late TabController _tabController;
  int _tabCount = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);

    ever(_profileController.isApproved, (bool approved) {
      final newCount = approved ? 2 : 1;
      if (_tabCount != newCount) {
        final oldIndex = _tabController.index;

        _tabController.dispose();
        _tabController = TabController(length: newCount, vsync: this);
        // Restore the index if possible
        _tabController.index = oldIndex.clamp(0, newCount - 1);
        _tabCount = newCount;
        if (mounted) setState(() {});
      }
    });
    _loadUserDetails();
    _loadUserPosts();
    _profileController.fetchVerificationStatus().then((_) {
      if (mounted && _profileController.isApproved.value) {
        _loadUserArticles();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      _isLoadingProfile = true;
      _errorProfile = null;
    });
    try {
      final userProfile = await ApiService().fetchUserProfile();
      if (!mounted) return;
      setState(() {
        _userProfile = userProfile;
        _isLoadingProfile = false;
      });
      await _profileController.fetchVerificationStatus();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorProfile = e.toString();
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadUserPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId != null) {
      try {
        final posts = await _postController.fetchUserPosts(userId);
        if (!mounted) return;
        setState(() {
          _userPosts = posts;
          _isLoadingPosts = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoadingPosts = false;
        });
        debugPrint("Error fetching user posts: $e");
      }
    }
  }

  Future<void> _loadUserArticles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId != null) {
      try {
        final articles = await ApiService().fetchUserArticles(userId);
        if (!mounted) return;
        setState(() {
          _userArticles = articles;
          _isLoadingArticles = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoadingArticles = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      try {
        final response = await ApiService().updateProfilePicture(imageFile);
        if (response.statusCode == 200) {
          await _loadUserDetails();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading:${e.toString()}')),
        );
      }
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: Text(AppLocalizations.of(context)!.takePhoto),
              onTap: () async {
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 200));
                if (!mounted) return;
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.chooseFromGallery),
              onTap: () async {
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 200));
                if (!mounted) return;

                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorProfile != null) {
      return Center(child: Text('Error: $_errorProfile'));
    }

    final profileImageUrl = _userProfile?['profile_image'] ?? '';
    final userName = _userProfile?['name'] ?? "Unknown User";
    final userEmail = _userProfile?['email'] ?? "Unknown Email";
    final isApproved = _profileController.isApproved.value;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Profile header and info (scrollable)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Top Profile Container
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5)
                    ],
                  ),
                  padding: const EdgeInsets.only(
                      top: 40, left: 20, right: 20, bottom: 20),
                  child: Column(
                    children: [
                      // App title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Sende",
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'PlusJakartaSans',
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Profile Info
                      Text(AppLocalizations.of(context)!.myProfile,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Picture
                          GestureDetector(
                            onTap: _showImagePicker,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: profileImageUrl.isNotEmpty
                                      ? NetworkImage(profileImageUrl)
                                      : const AssetImage(
                                              "assets/images/splash1.png")
                                          as ImageProvider,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.camera_alt,
                                        size: 18, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // User Details (Name & Email)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Text(
                                      userName.isNotEmpty
                                          ? '${userName[0].toUpperCase()}${userName.substring(1).toLowerCase()}'
                                          : "Unknown User",
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Positioned(
                                      top: -10,
                                      left: 100,
                                      child: Obx(() {
                                        if (_profileController
                                            .isApproved.value) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: hexToColor('50A865')),
                                            ),
                                            child: Text(
                                              'Expert',
                                              style: TextStyle(
                                                color: hexToColor('006400'),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      }),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () async {
                                    final Uri emailUri =
                                        Uri(scheme: 'mailto', path: userEmail);
                                    if (await canLaunchUrl(emailUri)) {
                                      await launchUrl(emailUri);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Could not launch email')),
                                      );
                                    }
                                  },
                                  child: Text(
                                    userEmail,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.blue),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () =>
                                      Get.to(() => const EditProfilePage()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                  ),
                                  child: Text(
                                      AppLocalizations.of(context)!.editProfile,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Tabs Section
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      text: AppLocalizations.of(context)!.posts,
                    ),
                    if (isApproved)
                      Tab(text: AppLocalizations.of(context)!.articles),
                  ],
                  labelStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Posts Tab
                      _isLoadingPosts
                          ? const Center(child: CircularProgressIndicator())
                          : _userPosts.isEmpty
                              ? const Center(child: Text('No posts yet'))
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemCount: _userPosts.length,
                                    itemBuilder: (context, index) {
                                      final post = _userPosts[index];
                                      // ... your post widget ...
                                      return Card(
                                        child: Center(
                                          child: Text(post.title ?? 'No Title'),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                      // Articles Tab (only if approved)
                      if (isApproved)
                        _isLoadingArticles
                            ? const Center(child: CircularProgressIndicator())
                            : _userArticles.isEmpty
                                ? const Center(child: Text('No articles yet'))
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: _userArticles.length,
                                      itemBuilder: (context, index) {
                                        final article = _userArticles[index];
                                        // ... your article widget ...
                                        return Card(
                                          child: Center(
                                            child: Text(
                                                article.title ?? 'No Title'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isApproved
          ? FloatingActionButton.extended(
              onPressed: () {
                Get.to(() => CreatePostPage(userId: ''));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Article'),
              backgroundColor: hexToColor('FFD700'),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(30), // Adjust the value as needed
              ),
            )
          : null,
    );
  }
}
