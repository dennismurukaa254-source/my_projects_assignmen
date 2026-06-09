import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final Post post;
  const EditPostScreen({super.key, required this.post});

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  late TextEditingController _contentController;
  late String _selectedCategory;
  List<String> _imageUrls = [];
  List<XFile> _newImages = [];
  List<Uint8List> _newImageBytes = [];
  bool _isSaving = false;

  final List<String> _categories = [
    'Family News', 'Weddings', 'Birthdays', 'Graduations', 'Business Updates', 'Achievements',
  ];

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    _selectedCategory = widget.post.category;
    _imageUrls = List.from(widget.post.imageUrls);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickNewImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      final bytesList = <Uint8List>[];
      for (var img in images) {
        final bytes = await img.readAsBytes();
        bytesList.add(bytes);
      }
      setState(() {
        _newImages.addAll(images);
        _newImageBytes.addAll(bytesList);
      });
    }
  }

  Future<List<String>> _uploadNewImages() async {
    List<String> urls = [];
    for (int i = 0; i < _newImages.length; i++) {
      final bytes = _newImageBytes[i];
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}_${i}.jpg';
      final ref = FirebaseStorage.instance.ref().child('posts/$fileName');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      // Upload new images
      final newUrls = await _uploadNewImages();
      final allUrls = [..._imageUrls, ...newUrls];

      // Update Firestore
      await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).update({
        'content': _contentController.text.trim(),
        'category': _selectedCategory,
        'imageUrls': allUrls,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      // Delete post document
      await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).delete();
      // Optionally delete images from Storage (you can implement if needed)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
      _newImageBytes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: const Color(0xFF0A2F44),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deletePost,
            tooltip: 'Delete Post',
          ),
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Post Content', border: OutlineInputBorder()),
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
            const Text('Existing Images', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_imageUrls.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length,
                  itemBuilder: (ctx, i) => Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.network(_imageUrls[i], width: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 0,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 20),
                          onPressed: () => _removeExistingImage(i),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text('No images', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('New Images (will be added)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_newImageBytes.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newImageBytes.length,
                  itemBuilder: (ctx, i) => Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.memory(_newImageBytes[i], width: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 0,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 20),
                          onPressed: () => _removeNewImage(i),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickNewImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Images'),
            ),
            if (_isSaving) const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}