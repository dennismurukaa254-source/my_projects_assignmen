import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../directory/models/family_member.dart';

final membersListProvider = FutureProvider<List<FamilyMember>>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('family_members').get();
  return snapshot.docs.map((doc) => FamilyMember.fromMap(doc.id, doc.data())).toList();
});

class FamilyTreeNode {
  final FamilyMember member;
  final List<FamilyTreeNode> children;
  FamilyTreeNode({required this.member, this.children = const []});
}

final familyTreeProvider = Provider<List<FamilyTreeNode>>((ref) {
  final members = ref.watch(membersListProvider).value ?? [];
  if (members.isEmpty) return [];

  final memberMap = {for (var m in members) m.id: m};
  final childrenMap = <String, List<FamilyMember>>{};
  for (var m in members) {
    if (m.parentId != null && m.parentId!.isNotEmpty) {
      childrenMap.putIfAbsent(m.parentId!, () => []).add(m);
    }
  }

  FamilyTreeNode buildNode(FamilyMember member) {
    final childMembers = childrenMap[member.id] ?? [];
    final children = childMembers.map((c) => buildNode(c)).toList();
    return FamilyTreeNode(member: member, children: children);
  }

  final roots = members.where((m) => m.parentId == null || m.parentId!.isEmpty || !memberMap.containsKey(m.parentId)).toList();
  return roots.map((r) => buildNode(r)).toList();
});

// Single root provider for chart
final familyTreeRootProvider = Provider<FamilyTreeNode?>((ref) {
  final members = ref.watch(membersListProvider).value ?? [];
  if (members.isEmpty) return null;

  final memberMap = {for (var m in members) m.id: m};
  final childrenMap = <String, List<FamilyMember>>{};
  for (var m in members) {
    if (m.parentId != null && m.parentId!.isNotEmpty) {
      childrenMap.putIfAbsent(m.parentId!, () => []).add(m);
    }
  }

  FamilyTreeNode buildNode(FamilyMember member) {
    final childMembers = childrenMap[member.id] ?? [];
    final children = childMembers.map((c) => buildNode(c)).toList();
    return FamilyTreeNode(member: member, children: children);
  }

  final rootMember = members.firstWhere(
        (m) => m.parentId == null || m.parentId!.isEmpty || !memberMap.containsKey(m.parentId),
    orElse: () => members.first,
  );
  return buildNode(rootMember);
});