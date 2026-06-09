import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _contentController = TextEditingController();
  String _selectedCategory = 'Family News';
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _imageBytes = [];
  bool _isUploading = false;

  final List<String> _categories = [
    'Family News', 'Weddings', 'Birthdays', 'Graduations', 'Business Updates', 'Achievements',
  ];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      final bytesList = <Uint8List>[];
      for (var img in images) {
        final bytes = await img.readAsBytes();
        bytesList.add(bytes);
      }
      setState(() {
        _selectedImages.addAll(images);
        _imageBytes.addAll(bytesList);
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> urls = [];
    for (int i = 0; i < _selectedImages.length; i++) {
      final image = _selectedImages[i];
      final bytes = _imageBytes[i];
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}_${i}.jpg';
      final ref = FirebaseStorage.instance.ref().child('posts/$fileName');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some content or images')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final displayName = user.displayName ?? user.email ?? 'Anonymous';

      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _uploadImages();
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'authorId': user.uid,
        'authorName': displayName,
        'content': _contentController.text.trim(),
        'imageUrls': imageUrls,
        'videoUrls': [],
        'category': _selectedCategory,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'commentsCount': 0,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: const Color(0xFF0A2F44),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _createPost,
            child: const Text('Post', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'What\'s on your mind?',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            if (_imageBytes.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageBytes.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.memory(_imageBytes[i], width: 100, fit: BoxFit.cover),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('Add Images'),
            ),
            if (_isUploading) const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}