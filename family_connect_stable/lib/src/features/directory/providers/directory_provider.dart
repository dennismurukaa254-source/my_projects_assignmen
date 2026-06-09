import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_member.dart';

final directoryProvider = FutureProvider<List<FamilyMember>>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('family_members').get();
  return snapshot.docs.map((doc) => FamilyMember.fromMap(doc.id, doc.data())).toList();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final branchFilterProvider = StateProvider<String?>((ref) => null);

final filteredDirectoryProvider = Provider<List<FamilyMember>>((ref) {
  final members = ref.watch(directoryProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final branch = ref.watch(branchFilterProvider);
  return members.where((member) {
    if (query.isNotEmpty && !member.fullName.toLowerCase().contains(query)) return false;
    if (branch != null && member.branch != branch) return false;
    return true;
  }).toList();
});