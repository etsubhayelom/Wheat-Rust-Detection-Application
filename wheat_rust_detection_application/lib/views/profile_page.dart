import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wheat_rust_detection_application/services/api_services.dart';
import 'package:wheat_rust_detection_application/auth/login.dart';
import 'package:wheat_rust_detection_application/constants.dart';
import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';
import 'package:wheat_rust_detection_application/controllers/profile_controller.dart';
import 'package:wheat_rust_detection_application/views/create_articles_page.dart';

import 'package:wheat_rust_detection_application/views/edit_profile.dart';

import '../models/post_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final ProfileController _profileController = Get.put(ProfileController());
  Map<String, dynamic>? _userProfile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingProfile = true;
  String? _errorProfile;
  List<Post> _userPosts = [];
  List<Post> _userArticles = [];
  List<Post> _savedPosts = [];
  bool _isLoadingSaved = true;
  bool _isLoadingPosts = true;
  bool _isLoadingArticles = true;
  final PostController _postController = PostController();
  late TabController _tabController;
  late Worker _approvedListener;
  int _tabCount = 1;

  @override
  void initState() {
    super.initState();
    _tabCount = _profileController.isApproved.value ? 3 : 2;
    _tabController = TabController(length: _tabCount, vsync: this);

    _approvedListener = ever(_profileController.isApproved, (bool approved) {
      final newCount = approved ? 3 : 2;
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
    _loadSavedPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _approvedListener.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      _isLoadingProfile = true;
      _errorProfile = null;
    });
    try {
      await _profileController.fetchVerificationStatus();
      final userProfile = await ApiService().fetchUserProfile();
      if (!mounted) return;
      setState(() {
        _userProfile = userProfile;
        _isLoadingProfile = false;
      });
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
        final posts = await _postController.fetchUserPosts();
        if (!mounted) return;
        setState(() {
          _userPosts = posts
              .where(
                  (post) => post.userId == userId && post.postType != 'article')
              .toList();
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
          _userArticles = articles
              .where((article) =>
                  article.userId == userId && article.postType == 'article')
              .toList();
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

  Future<void> _loadSavedPosts() async {
    try {
      await _postController.fetchSavedPosts();
      setState(() {
        _savedPosts = _postController.savedPosts;
        _isLoadingSaved = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSaved = false;
      });
      debugPrint("Error fetching saved posts: $e");
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

  void _showDeleteDialog(Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('delete'),
          content: const Text('are you sure you want to delete'),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.no),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePost(post);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(Post post) async {
    try {
      await _postController.deletePost(post.id); // Your delete logic
      setState(() {
        _userPosts.removeWhere((p) => p.id == post.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post Deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'failed to delete'}: $e')),
      );
    }
  }

// void _editPost(Post post) {
//   // Navigate to your edit page, or show an edit dialog
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => CreateArticlePage(post: post, isEditing: true),
//     ),
//   );
// }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    debugPrint('Refresh token form shared preferences: $refreshToken');

    final response = await ApiService().logout(refreshToken);
    debugPrint('api response: ${response.body}');

    if (response.statusCode == 205) {
      // Logout successful
      await prefs.clear();
      Get.offAll(() => const LoginPage());
    } else {
      // Logout failed, show error
      String errorMsg = 'Logout failed. Please try again.';
      try {
        final body = jsonDecode(response.body);
        if (body['detail'] != null) errorMsg = body['detail'];
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.logOut,
          ),
          content:
              Text(AppLocalizations.of(context)!.areYouSureYouWantToLogout),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog, stay on page
              },
              child: Text(AppLocalizations.of(context)!.no),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                await _logout(context);
              },
              child: Text(AppLocalizations.of(context)!.yes),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(
    Post post, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Stack(
        children: [
          // The post image fills the card
          post.images != null && post.images!.isNotEmpty
              ? Image.network(
                  post.images!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 60),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: 400,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 60),
                ),
          // Gradient overlay for text readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Title and description overlay
          Positioned(
            bottom: 8,
            left: 16,
            right: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.title != null && post.title!.isNotEmpty)
                  Text(
                    post.title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (post.description != null && post.description!.isNotEmpty)
                  Text(
                    post.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Menu button (edit/delete)
          Align(
            alignment: Alignment.topRight,
            child: PopupMenuButton<String>(
              color: Colors.white,
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (String value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        ],
      ),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sende",
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'PlusJakartaSans',
                                color: Colors.green[700],
                              ),
                            ),
                            PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.black,
                                ),
                                onSelected: (value) {
                                  _showLogoutDialog(context);
                                },
                                itemBuilder: (BuildContext context) => [
                                      PopupMenuItem<String>(
                                        value: 'logout',
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .logOut),
                                      )
                                    ])
                          ],
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
                                              AppLocalizations.of(context)!
                                                  .expert,
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
                    Tab(
                      text: AppLocalizations.of(context)!.saved,
                    )
                  ],
                  labelStyle: const TextStyle(
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
                                      return _buildPostCard(
                                        post,
                                        onEdit: () {
                                          // Navigate to edit page or show edit dialog
                                        },
                                        onDelete: () {
                                          _showDeleteDialog(post);
                                        },
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
                                        return _buildPostCard(
                                          article,
                                          onEdit: () {
                                            // Navigate to edit page or show edit dialog
                                          },
                                          onDelete: () {
                                            _showDeleteDialog(article);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                      _isLoadingSaved
                          ? const Center(child: CircularProgressIndicator())
                          : _savedPosts.isEmpty
                              ? Center(
                                  child: Text(AppLocalizations.of(context)!
                                      .noSavedPosts))
                              : ListView.builder(
                                  itemCount: _savedPosts.length,
                                  itemBuilder: (context, index) {
                                    final post = _savedPosts[index];
                                    return Card(
                                      child: Center(
                                        child: Text(post.description ?? ''),
                                      ),
                                    );
                                  },
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
              onPressed: _profileController.isApproved.value
                  ? () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final userId = prefs.getString('user_id');
                      if (userId != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    CreateArticlePage(userId: userId)));
                      }
                    }
                  : null,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.addArticle),
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
