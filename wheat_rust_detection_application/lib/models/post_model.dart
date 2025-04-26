class Post {
  final String id;
  final String userId;
  final String userName;
  final String? description;
  final String? images;
  final String? audio;
  final DateTime? createdAt;
  final int likesCount;
  final int commentsCount;
  final List<Comment> comments;

  final String? postType;
  final String? title;

  const Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.audio,
    this.description,
    this.images,
    this.createdAt,
    required this.commentsCount,
    required this.likesCount,
    required this.comments,
    this.postType,
    this.title,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    List<Comment> commentsList = [];

    if (json['comments'] != null && json['comments'] is List) {
      commentsList = (json['comments'] as List)
          .map((commentJson) => Comment.fromJson(commentJson))
          .toList();
    }
    return Post(
      id: json['id'].toString(),
      userId: json['user'].toString(),
      userName: _capitalizeName(json['user_name'] as String),
      description: json['text'] as String?,
      images: json['image'],
      audio: json['audio'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      comments: commentsList,
      postType: json['post_type'] as String?,
      title: json['title'] as String?,
    );
  }

  String get timeAgo {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }

  static String _capitalizeName(String name) {
    if (name.isEmpty) return '';

    List<String> words = name.split(' ');
    List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    return capitalizedWords.join(' ');
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
