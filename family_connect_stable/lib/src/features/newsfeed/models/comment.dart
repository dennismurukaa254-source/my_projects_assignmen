import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Comment.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['timestamp'];
    return Comment(
      id: id,
      postId: map['postId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      content: map['content'] ?? '',
      timestamp: timestamp is Timestamp ? timestamp.toDate() : DateTime.parse(timestamp),
    );
  }
}