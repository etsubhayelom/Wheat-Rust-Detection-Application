import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/constants.dart';

class PostDetailsPage extends StatelessWidget {
  const PostDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // Positioned(
          //     top: 16.sp,
          //     left: 16.sp,
          //     right: 16.sp,
          //     child: CircleAvatar(
          //       radius: 22.sp,
          //       backgroundColor: Colors.grey[800],
          //       child: IconButton(
          //           onPressed: () {},
          //           icon: Icon(
          //             Icons.arrow_back,
          //             color: Colors.black,
          //             size: 22.sp,
          //           )),
          //     )),
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Image.asset(
              'assets/splash1.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Post Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Section
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.yellow[700],
                              child:
                                  const Icon(Icons.person, color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ayele Dumamo",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[700],
                                  ),
                                ),
                                Text(
                                  "2 h",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Post Title
                        const Text(
                          "Help identifying the problem with my Wheat",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 5),

                        // Post Description
                        const Text(
                          "The app has already given me a possible problem with my Wheat. It said it has a stem rust but the medicine recommended is not available in my area. Does anyone know any other alternative? or where I could find medicine for stem rust pls!",
                          style: TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 15),

                        // Like, Comment, Share Buttons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.thumb_up_off_alt,
                                  color: Colors.black54),
                              onPressed: () {},
                            ),
                            const Text("0"),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.mode_comment_outlined,
                                  color: Colors.black54),
                              onPressed: () {},
                            ),
                            const Text("0"),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.share,
                                  color: Colors.black54),
                              onPressed: () {},
                            ),
                            const Text("3"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // No Comments Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "No comments yet",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Comment Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 5),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Write your answer",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: hexToColor('D9D9D9'),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: hexToColor('757575'),
                    ),
                    onPressed: () {},
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
