import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';
import 'package:wheat_rust_detection_application/models/post_model.dart';
import 'package:wheat_rust_detection_application/views/audio_preview.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final PostController postController;

  final bool isLikedByUser;

  const PostCard({
    super.key,
    required this.post,
    required this.postController,
    this.isLikedByUser = false,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likesCount;
  late int _commentsCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLikedByUser;
    _likesCount = widget.post.likesCount;
    _commentsCount = widget.post.commentsCount;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        (widget.post.images != null && widget.post.images!.isNotEmpty);
    final hasAudio =
        (widget.post.audio != null && widget.post.audio!.isNotEmpty);
    final hasDescription = (widget.post.description != null &&
        widget.post.description!.trim().isNotEmpty);
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            Image.network(
              widget.post.images!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          else if (hasAudio)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: AudioPreviewPlayer(
                audioFilePath: widget.post.audio!,
                onDelete: () {},
              ),
            )
          else
            _buildPlaceholder(),
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
                if (hasDescription)
                  Text(
                    widget.post.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  )
                else if (!hasImage && !hasAudio)
                  const Text(
                    'No description',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                const SizedBox(height: 10),

                // Action Buttons (like, comment, share)
                const Divider(),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
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
            color: _isLiked ? Colors.red : null,
          ),
          onPressed: () {
            if (_isLiked) {
              widget.postController.dislikePost(widget.post.id);
              setState(() {
                _likesCount = (_likesCount > 0) ? _likesCount - 1 : 0;
                _isLiked = false;
              });
            } else {
              widget.postController.likePost(widget.post.id);
              setState(() {
                _likesCount += 1;
                _isLiked = true;
              });
            }
          },
        ),
        const SizedBox(width: 4),
        Text('$_likesCount'),
        IconButton(
            icon: const Icon(Icons.comment_outlined),
            onPressed: _buildCommentsSection),
        const SizedBox(width: 4),
        Text('$_commentsCount'),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'save') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post saved')),
              );
            } else if (value == 'report') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post reported')),
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'save',
              child: Text('Save'),
            ),
            const PopupMenuItem<String>(
              value: 'report',
              child: Text('Report'),
            ),
          ],
        ),
      ],
    );
  }

  // Widget to build the comments section
  Widget _buildCommentsSection() {
    if (widget.post.comments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.post.comments.map((comment) {
        // Handle null comments
        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${comment.userName}: ${comment.text}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        );
      }).toList(),
    );
  }
}
