import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final String category;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;
  final int commentsCount;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.imageUrls,
    required this.videoUrls,
    required this.category,
    required this.timestamp,
    required this.likes,
    required this.likedBy,
    required this.commentsCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'category': category,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'likedBy': likedBy,
      'commentsCount': commentsCount,
    };
  }

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['timestamp'];
    return Post(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      content: map['content'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrls: List<String>.from(map['videoUrls'] ?? []),
      category: map['category'] ?? 'Family News',
      timestamp: timestamp is Timestamp ? timestamp.toDate() : DateTime.parse(timestamp),
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      commentsCount: map['commentsCount'] ?? 0,
    );
  }
}