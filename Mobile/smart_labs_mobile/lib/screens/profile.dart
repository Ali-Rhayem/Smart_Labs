import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/provider_reset.dart';
import 'package:smart_labs_mobile/providers/theme_provider.dart';
import 'package:smart_labs_mobile/providers/user_provider.dart';
import 'package:smart_labs_mobile/screens/edit_profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';

// Example accent color (the bright yellow)
const Color kNeonYellow = Color(0xFFFFEB00);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                backgroundImage: user.imageUrl != null
                    ? NetworkImage(
                        '${dotenv.env['IMAGE_BASE_URL']}/${user.imageUrl}')
                    : const NetworkImage('https://picsum.photos/200'),
                onBackgroundImageError: (_, __) =>
                    const NetworkImage('https://picsum.photos/200'),
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
                color: Colors.white.withValues(alpha: 0.7),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(user: user),
                  ),
                );
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
              icon: Icons.brightness_6,
              title: 'Theme',
              trailing: Consumer(
                builder: (context, ref, child) {
                  final isDark = ref.watch(themeProvider) == ThemeMode.dark;
                  return Switch(
                    value: isDark,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                    activeColor: kNeonYellow,
                    activeTrackColor: kNeonYellow.withValues(alpha: 0.3),
                  );
                },
              ),
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                // TODO: Navigate to settings
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
              onTap: () async {
                final secureStorage = SecureStorage();
                final firebaseMessaging = FirebaseMessaging.instance;

                await firebaseMessaging.deleteToken();

                await secureStorage.clearAll();

                if (!context.mounted) return;

                resetAllProviders(ref);

                // Navigate to login screen and remove all previous routes
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
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
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: kNeonYellow),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.white),
      onTap: onTap,
    );
  }
}
