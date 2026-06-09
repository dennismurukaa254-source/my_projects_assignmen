import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tree_provider.dart';
import '../../directory/models/family_member.dart';

class AddToTreeScreen extends ConsumerStatefulWidget {
  const AddToTreeScreen({super.key});

  @override
  ConsumerState<AddToTreeScreen> createState() => _AddToTreeScreenState();
}

class _AddToTreeScreenState extends ConsumerState<AddToTreeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _branchController = TextEditingController();
  final _locationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _biographyController = TextEditingController();
  final _photoUrlController = TextEditingController();
  String? _selectedGender;
  String? _selectedParentId;

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _branchController.dispose();
    _locationController.dispose();
    _occupationController.dispose();
    _biographyController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newMember = {
        'fullName': _fullNameController.text.trim(),
        'gender': _selectedGender,
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'branch': _branchController.text.trim(),
        'location': _locationController.text.trim(),
        'occupation': _occupationController.text.trim(),
        'biography': _biographyController.text.trim(),
        'photoUrl': _photoUrlController.text.trim(),
        'parentId': _selectedParentId ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('family_members').add(newMember);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family member added to tree!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member to Family Tree'),
        backgroundColor: const Color(0xFF0A2F44),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()),
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) => value == null ? 'Select gender' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _branchController,
                decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(labelText: 'Occupation', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _biographyController,
                decoration: const InputDecoration(labelText: 'Biography', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(labelText: 'Photo URL (optional)', border: OutlineInputBorder(), hintText: 'https://...'),
              ),
              const SizedBox(height: 12),
              membersAsync.when(
                data: (members) {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Parent (optional)', border: OutlineInputBorder()),
                    value: _selectedParentId,
                    items: [
                      const DropdownMenuItem(value: '', child: Text('None (root)')),
                      ...members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.fullName))),
                    ],
                    onChanged: (value) => setState(() => _selectedParentId = value),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error loading members: $err'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0A2F44),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Add Member to Tree'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}