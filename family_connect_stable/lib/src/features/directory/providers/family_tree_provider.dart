import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_member.dart';
import 'directory_provider.dart'; // for the list of members

class FamilyTreeNode {
  final FamilyMember member;
  List<FamilyTreeNode> children;

  FamilyTreeNode({required this.member, this.children = const []});
}

final familyTreeProvider = Provider<FamilyTreeNode?>((ref) {
  final members = ref.watch(directoryProvider).value ?? [];
  if (members.isEmpty) return null;

  // Find root nodes (members with no parentId)
  final rootMembers = members.where((m) => m.parentId == null).toList();
  if (rootMembers.isEmpty) return null;

  // Build a map for quick lookup
  final memberMap = {for (var m in members) m.id: m};
  final childrenMap = <String, List<String>>{};
  for (var m in members) {
    if (m.parentId != null) {
      childrenMap.putIfAbsent(m.parentId!, () => []).add(m.id);
    }
  }

  // Recursive builder
  FamilyTreeNode buildNode(String memberId) {
    final member = memberMap[memberId]!;
    final childIds = childrenMap[memberId] ?? [];
    return FamilyTreeNode(
      member: member,
      children: childIds.map(buildNode).toList(),
    );
  }

  // For simplicity, we take the first root (you can change to a list if multiple roots)
  return buildNode(rootMembers.first.id);
});