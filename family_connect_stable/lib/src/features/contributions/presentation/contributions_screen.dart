import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/contributions_provider.dart';
import 'add_contribution_screen.dart';
import 'edit_contribution_screen.dart';
import 'treasurer_dashboard.dart';

class ContributionsScreen extends ConsumerStatefulWidget {
  const ContributionsScreen({super.key});

  @override
  ConsumerState<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends ConsumerState<ContributionsScreen> {
  Future<void> _refreshContributions() async {
    ref.invalidate(contributionsStreamProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _deleteContribution(String id) async {
    try {
      await FirebaseFirestore.instance.collection('contributions').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contribution deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contributionsAsync = ref.watch(contributionsStreamProvider);
    final total = ref.watch(totalContributionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contributions'),
        backgroundColor: const Color(0xFF0A2F44),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddContributionScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TreasurerDashboard()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshContributions,
        child: contributionsAsync.when(
          data: (contributions) {
            if (contributions.isEmpty) {
              return const Center(child: Text('No contributions yet'));
            }
            return Column(
              children: [
                // Total contributions card
                Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Total Contributions',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('KES ${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37))),
                      ],
                    ),
                  ),
                ),
                // Contribution list with numbering
                Expanded(
                  child: ListView.builder(
                    itemCount: contributions.length,
                    itemBuilder: (context, index) {
                      final c = contributions[index];
                      return Dismissible(
                        key: Key(c.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Contribution'),
                              content: const Text('Are you sure you want to delete this contribution?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ) ?? false;
                        },
                        onDismissed: (direction) => _deleteContribution(c.id),
                        child: ListTile(
                          leading: Text(
                            '${index + 1}.', // Numbering
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          title: Text(c.memberName),
                          subtitle: Text('${c.date.toLocal()}'),
                          trailing: Text('KES ${c.amount.toStringAsFixed(2)}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditContributionScreen(contribution: c),
                              ),
                            ).then((_) => _refreshContributions());
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}