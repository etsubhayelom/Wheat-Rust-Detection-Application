import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheat_rust_detection_application/constants.dart';
import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';
import 'package:wheat_rust_detection_application/models/post_model.dart';

class PostDetailsPage extends StatefulWidget {
  final Post post;
  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.post.comments);
  }

  void _addComment(String commentText) async {
    if (commentText.isNotEmpty) {
      final newComment =
          await Provider.of<PostController>(context, listen: false)
              .createComment(postId: widget.post.id, comment: commentText);

      if (newComment != null) {
        setState(() {
          _comments.add(newComment);
          _commentController.clear();
        });
      } else {
        // Handle the error
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add comment')));
      }
    }
  }

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
            child: widget.post.images != null && widget.post.images!.isNotEmpty
                ? Image.network(
                    widget.post.images!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/splash1.png',
                    height: 300,
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
                                  widget.post.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  widget.post.timeAgo,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Post Title
                        if (widget.post.title != null)
                          Text(
                            widget.post.title!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        const SizedBox(height: 5),

                        // Post Description
                        Text(
                          widget.post.description ?? "",
                          style: const TextStyle(color: Colors.black87),
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
                            Text("${widget.post.likesCount}"),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.mode_comment_outlined,
                                  color: Colors.black54),
                              onPressed: () {},
                            ),
                            Text("${widget.post.commentsCount}"),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.share,
                                  color: Colors.black54),
                              onPressed: () {},
                            ),
                            const Text("0"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Comments Section
                  _comments.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey, width: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child:
                                        Icon(Icons.person, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.userId,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(comment.text),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                      : Container(
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
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
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
                      onPressed: () {
                        _addComment(_commentController.text);
                      }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
