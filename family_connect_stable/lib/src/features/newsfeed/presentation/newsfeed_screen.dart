import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/newsfeed_provider.dart';
import 'create_post_screen.dart';
import 'comments_dialog.dart';
import 'edit_post_screen.dart';  // <-- Import the edit screen

class NewsFeedScreen extends ConsumerWidget {
  const NewsFeedScreen({super.key});

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsStreamProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
        backgroundColor: const Color(0xFF0A2F44),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(postsStreamProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(postsStreamProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: postsAsync.when(
          data: (posts) {
            if (posts.isEmpty) {
              return const Center(child: Text('No posts yet. Create the first one!'));
            }
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final isLiked = currentUserId != null && post.likedBy.contains(currentUserId);
                final isAuthor = currentUserId == post.authorId;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(child: Icon(Icons.person)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    '${post.timestamp.toLocal()}'.substring(0, 16),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            if (isAuthor)
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => EditPostScreen(post: post)),
                                  );
                                  if (result == true) {
                                    // Optional: force refresh
                                    ref.invalidate(postsStreamProvider);
                                  }
                                },
                                tooltip: 'Edit post',
                              ),
                            Chip(
                              label: Text(post.category),
                              backgroundColor: const Color(0xFFD4AF37),
                              labelStyle: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (post.content.isNotEmpty) Text(post.content),
                        const SizedBox(height: 8),
                        if (post.imageUrls.isNotEmpty)
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: post.imageUrls.length,
                              itemBuilder: (ctx, i) => GestureDetector(
                                onTap: () => _showFullScreenImage(context, post.imageUrls[i]),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Image.network(
                                    post.imageUrls[i],
                                    width: 200,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 200,
                                        color: Colors.grey[300],
                                        child: const Center(child: CircularProgressIndicator()),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : null),
                              onPressed: () async {
                                await toggleLike(post.id, currentUserId!, isLiked);
                              },
                            ),
                            Text('${post.likes}'),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(Icons.comment),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => CommentsDialog(postId: post.id),
                                );
                              },
                            ),
                            Text('${post.commentsCount}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}