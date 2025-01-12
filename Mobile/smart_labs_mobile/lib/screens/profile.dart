import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/user_model.dart';

// Example accent color (the bright yellow)
const Color kNeonYellow = Color(0xFFFFEB00);

class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove or customize the AppBar if you want a different style
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Handle settings button tap
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1C1C1C), // Dark background

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // User avatar at the top
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.imageUrl),
              ),
            ),
            const SizedBox(height: 16),

            // User name
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),

            // User email
            Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // "Edit Profile" button
            ElevatedButton.icon(
              icon: const Icon(Icons.edit, color: Colors.black),
              label: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                // TODO: handle edit profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kNeonYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),

            // List of other items/sections:
            _buildProfileOption(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                // TODO: Navigate to settings
              },
            ),
            _buildProfileOption(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Billing Details',
              onTap: () {
                // TODO: Navigate to billing details
              },
            ),
            _buildProfileOption(
              icon: Icons.group_outlined,
              title: 'User Management',
              onTap: () {
                // TODO: Navigate to user management
              },
            ),
            _buildProfileOption(
              icon: Icons.info_outline,
              title: 'Information',
              onTap: () {
                // TODO: Show info
              },
            ),
            const SizedBox(height: 16),

            // Logout option in red
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade400),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
                // TODO: Handle logout
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build each item in the list
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kNeonYellow),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
      onTap: onTap,
    );
  }
}
