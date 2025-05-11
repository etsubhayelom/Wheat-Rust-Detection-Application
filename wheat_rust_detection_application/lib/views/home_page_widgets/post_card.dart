import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';
import 'package:wheat_rust_detection_application/models/post_model.dart';
import 'package:wheat_rust_detection_application/views/audio_preview.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final PostController postController;

  const PostCard({
    super.key,
    required this.post,
    required this.postController,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _isLiked = widget.post.likesCount as bool;
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          if (widget.post.audio != null && widget.post.audio!.isNotEmpty)
            AudioPreviewPlayer(
              audioFilePath: widget.post.audio!,
              onDelete: () {},
            ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.yellow[700],
                child: const Icon(Icons.person, color: Colors.black),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description Section
                Text(
                  widget.post.description ??
                      'No description', // Access the text property
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                // Action Buttons (like, comment, share)
                const Divider(),
                _buildActionButtons(),
                // Comments Section
                _buildCommentsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final imageUrl = widget.post.images ?? '';

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(child: Text('Image not available')),
    );
  }

  // Widget to build the action buttons
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(
            _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
            color: _isLiked ? Colors.blue : null,
          ),
          onPressed: () {
            if (_isLiked) {
              widget.postController.dislikePost(widget.post.id);
            } else {
              widget.postController.likePost(widget.post.id);
            }
            setState(() {
              _isLiked = !_isLiked;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.comment_outlined),
          onPressed: () {
            // // Navigate to comment page or show comment dialog
            // showDialog(
            //   context: context,
            //   builder: (context) => CommentDialog(
            //     postId: widget.post.id,
            //     postController: widget.postController,
            //   ),
            // );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  // Widget to build the comments section
  Widget _buildCommentsSection() {
    return Column(
      children: (widget.post.comments).map((comment) {
        // Handle null comments
        return Text(
          comment.text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        );
      }).toList(),
    );
  }
}

// class CommentDialog extends StatefulWidget {
//   final String postId;
//   final PostController postController;

//   const CommentDialog({
//     super.key,
//     required this.postId,
//     required this.postController,
//   });

//   @override
//   _CommentDialogState createState() => _CommentDialogState();
// }

// class _CommentDialogState extends State<CommentDialog> {
//   final TextEditingController _commentController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _commentController,
//               decoration: const InputDecoration(hintText: 'Write a comment'),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: () async {
//                 await widget.postController.createComment(
//                   widget.postId,
//                   _commentController.text,
//                 );
//                 Navigator.pop(context);
//               },
//               child: const Text('Post Comment'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
