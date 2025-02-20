import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/provider_reset.dart';
import 'package:smart_labs_mobile/providers/theme_provider.dart';
import 'package:smart_labs_mobile/providers/user_provider.dart';
import 'package:smart_labs_mobile/screens/edit_profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';
import 'package:smart_labs_mobile/screens/change_password.dart';

// Example accent color (the bright yellow)
const Color kNeonYellow = Color(0xFFFFEB00);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (user == null) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? kNeonYellow : theme.colorScheme.primary,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.settings,
        //       color: theme.colorScheme.onSurface,
        //     ),
        //     onPressed: () {
        //       // TODO: Handle settings button tap
        //     },
        //   ),
        // ],
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary,
                child: ClipOval(
                  child: Image.network(
                    '${dotenv.env['IMAGE_BASE_URL']}/${user.imageUrl}',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.primary,
                        alignment: Alignment.center,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: TextStyle(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon:
                  Icon(Icons.edit, color: isDark ? Colors.black : Colors.white),
              label: Text(
                'Edit Profile',
                style: TextStyle(color: isDark ? Colors.black : Colors.white),
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
                backgroundColor:
                    isDark ? kNeonYellow : theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileOption(
              context: context,
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            _buildProfileOption(
              context: context,
              icon: Icons.brightness_6,
              title: 'Theme',
              trailing: Consumer(
                builder: (context, ref, child) {
                  final isDark = ref.watch(themeProvider) == ThemeMode.dark;
                  return GestureDetector(
                    onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 70,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: isDark
                            ? const Color(0xFF3C3C3C)
                            : const Color(0xFFE0ECF8),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0xFF000000).withValues(alpha: 0.3)
                                : const Color(0xFF4A6FA5).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background stars (only visible in dark mode)
                          if (isDark) ...[
                            Positioned(
                              top: 7,
                              left: 42,
                              child: Container(
                                width: 2,
                                height: 2,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 15,
                              left: 48,
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: isDark ? 35 : 3,
                            top: 3,
                            child: Container(
                              width: 29,
                              height: 29,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? kNeonYellow
                                    : const Color(0xFFFFB156),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? kNeonYellow.withValues(alpha: 0.4)
                                        : const Color(0xFFFFB156)
                                            .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: isDark
                                  ? Stack(
                                      children: [
                                        // Moon crater details
                                        Positioned(
                                          top: 8,
                                          left: 6,
                                          child: Container(
                                            width: 4,
                                            height: 4,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF3C3C3C),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          right: 8,
                                          child: Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF3C3C3C),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFFFFB156),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFB156)
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 4,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              onTap: () {},
            ),
            const SizedBox(height: 16),
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

  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? kNeonYellow : theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurface,
          ),
      onTap: onTap,
    );
  }
}
