import 'package:keihatsu/models/user.dart';


class Comment {
  final String id;
  final String content;
  final List<String> images;
  final String userId;
  final User? user;
  final String mangaId;
  final String chapterId;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int upvotes;
  final int downvotes;
  final List<Comment> replies;
  final List<CommentVote>? votes;

  Comment({
    required this.id,
    required this.content,
    required this.images,
    required this.userId,
    this.user,
    required this.mangaId,
    required this.chapterId,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.replies = const [],
    this.votes,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      userId: json['userId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      mangaId: json['mangaId'],
      chapterId: json['chapterId'],
      parentId: json['parentId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e))
          .toList() ??
          [],
      votes: (json['votes'] as List<dynamic>?)
          ?.map((e) => CommentVote.fromJson(e))
          .toList(),
    );
  }
}

class CommentVote {
  final String type; // 'UPVOTE' or 'DOWNVOTE'

  CommentVote({required this.type});

  factory CommentVote.fromJson(Map<String, dynamic> json) {
    return CommentVote(type: json['type']);
  }
}
