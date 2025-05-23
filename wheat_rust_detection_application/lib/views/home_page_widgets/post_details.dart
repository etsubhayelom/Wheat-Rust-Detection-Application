import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheat_rust_detection_application/constants.dart';
import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';
import 'package:wheat_rust_detection_application/models/post_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final freshComments =
          await Provider.of<PostController>(context, listen: false)
              .fetchComments(postId: widget.post.id);
      setState(() {
        _comments = freshComments;
      });
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    }
  }

  void _addComment(String commentText) async {
    if (commentText.isNotEmpty) {
      final newComment =
          await Provider.of<PostController>(context, listen: false)
              .createComment(postId: widget.post.id, comment: commentText);

      if (newComment != null) {
        _commentController.clear();
        setState(() {
          _comments.insert(0, newComment);
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
                            Text("${_comments.length}"),
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
                              margin: const EdgeInsets.only(bottom: 8),
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
                                          comment.userName,
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
                            AppLocalizations.of(context)!.noCommentsYet,
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
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.writeYourAnswers,
                      hintStyle: const TextStyle(color: Colors.grey),
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
