import 'package:flutter/material.dart';
import 'package:family_connect_stable/src/features/directory/models/family_member.dart';

class ProfileScreen extends StatelessWidget {
  final FamilyMember member;

  const ProfileScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.fullName),
        backgroundColor: const Color(0xFF0A2F44),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture (or placeholder)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  image: (member.photoUrl != null && member.photoUrl!.isNotEmpty)
                      ? DecorationImage(
                    image: NetworkImage(member.photoUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: (member.photoUrl == null || member.photoUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Full Name
            _buildInfoRow(Icons.person, 'Full Name', member.fullName),
            const Divider(),

            // Branch
            if (member.branch != null && member.branch!.isNotEmpty)
              _buildInfoRow(Icons.account_tree, 'Branch', member.branch!),
            if ((member.branch != null && member.branch!.isNotEmpty)) const Divider(),

            // Phone
            if (member.phone != null && member.phone!.isNotEmpty)
              _buildInfoRow(Icons.phone, 'Phone', member.phone!),
            if ((member.phone != null && member.phone!.isNotEmpty)) const Divider(),

            // Email
            if (member.email != null && member.email!.isNotEmpty)
              _buildInfoRow(Icons.email, 'Email', member.email!),
            if ((member.email != null && member.email!.isNotEmpty)) const Divider(),

            // Location
            if (member.location != null && member.location!.isNotEmpty)
              _buildInfoRow(Icons.location_on, 'Location', member.location!),
            if ((member.location != null && member.location!.isNotEmpty)) const Divider(),

            // Occupation
            if (member.occupation != null && member.occupation!.isNotEmpty)
              _buildInfoRow(Icons.work, 'Occupation', member.occupation!),
            if ((member.occupation != null && member.occupation!.isNotEmpty)) const Divider(),

            // Biography
            if (member.biography != null && member.biography!.isNotEmpty)
              _buildInfoRow(Icons.description, 'Biography', member.biography!,
                  isMultiline: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment:
        isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isMultiline ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}