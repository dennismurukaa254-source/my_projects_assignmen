import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tree_provider.dart';
import '../../directory/models/family_member.dart'; // ADD THIS IMPORT
import '../../directory/presentation/profile_screen.dart';
import 'add_to_tree_screen.dart';

class FamilyTreeScreen extends ConsumerWidget {
  const FamilyTreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final root = ref.watch(familyTreeRootProvider);
    final membersAsync = ref.watch(membersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Tree Chart'),
        backgroundColor: const Color(0xFF0A2F44),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddToTreeScreen()),
              );
            },
          ),
        ],
      ),
      body: membersAsync.when(
        data: (_) {
          if (root == null) {
            return const Center(child: Text('No family tree data. Add members and set parent relationships.'));
          }
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Center(
              child: _TreeNodeWidget(node: root, depth: 0),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _TreeNodeWidget extends StatelessWidget {
  final FamilyTreeNode node;
  final int depth;

  const _TreeNodeWidget({required this.node, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    final children = node.children.map((child) => _TreeNodeWidget(node: child, depth: depth + 1)).toList();

    if (children.isEmpty) {
      return _NodeCard(member: node.member, depth: depth);
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NodeCard(member: node.member, depth: depth),
          const SizedBox(height: 20),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 40,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: children,
            ),
          ],
        ],
      );
    }
  }
}

class _NodeCard extends StatelessWidget {
  final FamilyMember member;
  final int depth;

  const _NodeCard({required this.member, required this.depth});

  @override
  Widget build(BuildContext context) {
    String? relationshipLabel;
    if (depth == 1) relationshipLabel = member.gender == 'Male' ? 'Father' : 'Mother';
    else if (depth == 2) relationshipLabel = member.gender == 'Male' ? 'Grandfather' : 'Grandmother';
    else if (depth >= 3) relationshipLabel = member.gender == 'Male' ? 'Great Grandfather' : 'Great Grandmother';

    final title = relationshipLabel == null ? member.fullName : '$relationshipLabel: ${member.fullName}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen(member: member)),
        );
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: depth == 0 ? const Color(0xFFD4AF37) : const Color(0xFF0A2F44),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              member.gender == 'Male' ? Icons.male : Icons.female,
              color: depth == 0 ? const Color(0xFF0A2F44) : Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: depth == 0 ? const Color(0xFF0A2F44) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            if (member.branch != null)
              Text(
                member.branch!,
                style: TextStyle(
                  color: depth == 0 ? const Color(0xFF0A2F44) : Colors.white70,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}