class Post {
  final String id;
  final String userId;
  final String? description;
  final String? images;
  final int likes;
  final List<Comment> comments;
  final bool isLikedByUser;

  const Post(
      {required this.id,
      required this.userId,
      this.description,
      this.images,
      required this.likes,
      required this.comments,
      required this.isLikedByUser});

  factory Post.fromJson(Map<String, dynamic> json) {
    List<dynamic>? commentsJson = json['comments']; // Capture as nullable

    List<Comment> commentsList = [];

    if (commentsJson != null) {
      commentsList = commentsJson
          .map((commentJson) => Comment.fromJson(commentJson))
          .toList();
    }
    return Post(
      id: json['id'].toString(),
      userId: json['user'].toString(),
      description: json['text'] as String?,
      images: json['image'],
      likes: json['likes_count'] ?? 0,
      comments: commentsList,
      isLikedByUser: json['is_liked_by_user'] ?? false,
    );
  }
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String text;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      postId: json['post_id'].toString(),
      userId: json['user'].toString(),
      text: json['text'] as String,
    );
  }
}
