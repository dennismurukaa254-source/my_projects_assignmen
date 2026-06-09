import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import '../models/comment.dart';

final postsStreamProvider = StreamProvider<List<Post>>((ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .orderBy('timestamp', descending: true) // newest first
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Post.fromMap(doc.id, doc.data()))
      .toList());
});

final commentsStreamProvider = StreamProvider.family<List<Comment>, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection('comments')
      .where('postId', isEqualTo: postId)
      .orderBy('timestamp', descending: false) // oldest first (ascending)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Comment.fromMap(doc.id, doc.data()))
      .toList());
});

final currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

Future<void> toggleLike(String postId, String userId, bool isLiked) async {
  final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
  if (isLiked) {
    await postRef.update({
      'likes': FieldValue.increment(-1),
      'likedBy': FieldValue.arrayRemove([userId]),
    });
  } else {
    await postRef.update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }
}