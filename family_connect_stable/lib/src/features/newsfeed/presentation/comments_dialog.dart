import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/newsfeed_provider.dart';
import '../models/comment.dart';

class CommentsDialog extends ConsumerStatefulWidget {
  final String postId;
  const CommentsDialog({super.key, required this.postId});

  @override
  ConsumerState<CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends ConsumerState<CommentsDialog> {
  final TextEditingController _commentController = TextEditingController();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser!;
    final displayName = user.displayName ?? user.email ?? 'Anonymous';

    try {
      await FirebaseFirestore.instance.collection('comments').add({
        'postId': widget.postId,
        'authorId': user.uid,
        'authorName': displayName,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'commentsCount': FieldValue.increment(1),
      });
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await FirebaseFirestore.instance.collection('comments').doc(commentId).delete();
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'commentsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting comment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsStreamProvider(widget.postId));

    return Dialog(
      child: Container(
        height: 500,
        width: 350,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: commentsAsync.when(
                data: (comments) {
                  if (comments.isEmpty) {
                    return const Center(child: Text('No comments yet.'));
                  }
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (ctx, i) {
                      final c = comments[i];
                      final isAuthor = c.authorId == currentUserId;
                      return ListTile(
                        title: Text(c.authorName),
                        subtitle: Text(c.content),
                        trailing: isAuthor
                            ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteComment(c.id),
                        )
                            : null,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}