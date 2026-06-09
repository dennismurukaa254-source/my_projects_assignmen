import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_connect_stable/src/features/auth/providers/auth_provider.dart';
import 'package:family_connect_stable/src/features/directory/presentation/directory_screen.dart';
import 'package:family_connect_stable/src/features/family_tree/presentation/family_tree_screen.dart';
import 'package:family_connect_stable/src/features/contributions/presentation/contributions_screen.dart';
import 'package:family_connect_stable/src/features/newsfeed/presentation/newsfeed_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final DateTime _nextReunion = DateTime(2026, 12, 25); // Change to actual date

  String _getCountdownText() {
    final now = DateTime.now();
    final difference = _nextReunion.difference(now);
    if (difference.isNegative) return "The reunion has passed!";
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    return "$days days, $hours hours, $minutes minutes";
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final countdown = _getCountdownText();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Connect'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A2F44), Color(0xFF0D3B55)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.family_restroom, size: 48, color: Color(0xFFD4AF37)),
                  SizedBox(height: 8),
                  Text(
                    'Family Connect',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    'Connecting Generations, Preserving Legacy',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF0A2F44)),
              title: const Text('Home'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF0A2F44)),
              title: const Text('Family Directory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DirectoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.family_restroom, color: Color(0xFF0A2F44)),
              title: const Text('Family Tree'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FamilyTreeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Color(0xFF0A2F44)),
              title: const Text('Contributions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContributionsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper, color: Color(0xFF0A2F44)),
              title: const Text('News Feed'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewsFeedScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF0A2F44)),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gallery coming soon')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF0A2F44)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Settings screen
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 40, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user?.displayName ?? user?.email ?? "Family Member"}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text('Stay connected with your family'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Countdown Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: const Color(0xFF0A2F44),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Next Family Reunion',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(_nextReunion),
                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      countdown,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Family Statistics (placeholder – replace with real data later)
            const Text(
              'Family Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Members',
                    value: '342',
                    icon: Icons.people,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Branches',
                    value: '12',
                    icon: Icons.family_restroom,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Contributions',
                    value: 'KES 45,600',
                    icon: Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Active Members',
                    value: '287',
                    icon: Icons.person,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Upcoming Birthdays (placeholder)
            const Text(
              'Upcoming Birthdays',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cake, color: Color(0xFFD4AF37)),
                title: const Text('John Doe'),
                subtitle: const Text('Birthday: June 15, 2026'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cake, color: Color(0xFFD4AF37)),
                title: const Text('Jane Smith'),
                subtitle: const Text('Birthday: June 20, 2026'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 20),

            // Announcements Section
            const Text(
              'Announcements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.announcement, color: Color(0xFFD4AF37)),
                title: const Text('Annual General Meeting'),
                subtitle: const Text('June 30, 2026 at 2 PM'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.announcement, color: Color(0xFFD4AF37)),
                title: const Text('Family Fundraiser'),
                subtitle: const Text('Support education for our young ones'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quick action – coming soon')),
          );
        },
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.add, color: Color(0xFF0A2F44)),
      ),
    );
  }
}

// Helper widget for statistics cards
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFFD4AF37)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}