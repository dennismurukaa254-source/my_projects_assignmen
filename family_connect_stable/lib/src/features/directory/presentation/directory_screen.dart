import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/directory_provider.dart';
import '../models/family_member.dart';
import 'profile_screen.dart';
import 'add_member_screen.dart';   // <-- ADD THIS

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(directoryProvider);
    final filteredMembers = ref.watch(filteredDirectoryProvider);
    final branchFilter = ref.watch(branchFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Directory'),
        backgroundColor: const Color(0xFF0A2F44),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, branchFilter),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: membersAsync.when(
              data: (_) {
                if (filteredMembers.isEmpty) {
                  return const Center(child: Text('No family members found.'));
                }
                return ListView.builder(
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];
                    return MemberCard(member: member);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemberDialog(context),
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.add, color: Color(0xFF0A2F44)),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, String? currentBranch) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter by Branch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              onTap: () {
                ref.read(branchFilterProvider.notifier).state = null;
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Main Branch'),
              onTap: () {
                ref.read(branchFilterProvider.notifier).state = 'Main Branch';
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('East Branch'),
              onTap: () {
                ref.read(branchFilterProvider.notifier).state = 'East Branch';
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddMemberScreen(),
      ),
    ).then((result) {
      if (result == true) {
        ref.invalidate(directoryProvider);
      }
    });
  }
}

class MemberCard extends StatelessWidget {
  final FamilyMember member;

  const MemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: (member.photoUrl != null && member.photoUrl!.isNotEmpty)
            ? CircleAvatar(
          backgroundImage: NetworkImage(member.photoUrl!),
          onBackgroundImageError: (_, __) {},
        )
            : const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(member.fullName),
        subtitle: Text(member.branch ?? 'No branch specified'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileScreen(member: member),
            ),
          );
        },
      ),
    );
  }
}