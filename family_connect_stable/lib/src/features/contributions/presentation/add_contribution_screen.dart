import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../family_tree/providers/tree_provider.dart'; // Correct import
import '../../directory/models/family_member.dart';

class AddContributionScreen extends ConsumerStatefulWidget {
  const AddContributionScreen({super.key});

  @override
  ConsumerState<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends ConsumerState<AddContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedMemberId;
  String? _selectedMemberName;
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveContribution() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a family member')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('contributions').add({
        'memberId': _selectedMemberId,
        'memberName': _selectedMemberName,
        'amount': double.parse(_amountController.text.trim()),
        'date': _selectedDate.toIso8601String(),
        'notes': _notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contribution recorded!')),
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
        title: const Text('Add Contribution'),
        backgroundColor: const Color(0xFF0A2F44),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              membersAsync.when(
                data: (members) {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Family Member *'),
                    value: _selectedMemberId,
                    items: members.map((m) {
                      return DropdownMenuItem(
                        value: m.id,
                        child: Text(m.fullName),
                        onTap: () => _selectedMemberName = m.fullName,
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMemberId = value;
                        _selectedMemberName = members.firstWhere((m) => m.id == value).fullName;
                      });
                    },
                    validator: (value) => value == null ? 'Select a member' : null,
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error loading members: $err'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (KES) *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text('${_selectedDate.toLocal()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveContribution,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0A2F44),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Save Contribution'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}