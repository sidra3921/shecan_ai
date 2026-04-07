import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'settings_screen.dart';
import 'user_type_screen.dart';

Future<void> _logout(BuildContext context) async {
  await AuthService().signOut();
  if (!context.mounted) {
    return;
  }

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const UserTypeScreen()),
    (route) => false,
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final userId = authService.currentUserId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('Please sign in to view profile'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: firestoreService.streamUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final user = snapshot.data;

          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user.photoURL.isNotEmpty
                            ? NetworkImage(user.photoURL)
                            : null,
                        child: user.photoURL.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.bio.isNotEmpty ? user.bio : user.userType.toUpperCase(),
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      if (user.skills.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: user.skills.take(3).map((skill) {
                            return Chip(
                              label: Text(skill),
                              backgroundColor: Colors.white.withOpacity(0.2),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatColumn(
                            label: 'Projects',
                            value: '${user.completedProjects}',
                          ),
                          const SizedBox(width: 40),
                          _StatColumn(
                            label: 'Completed',
                            value: '${user.completedProjects}',
                          ),
                          const SizedBox(width: 40),
                          _StatColumn(
                            label: 'Rating',
                            value: user.rating > 0
                                ? user.rating.toStringAsFixed(1)
                                : 'N/A',
                          ),
                        ],
                      ),
                      if (user.hourlyRate > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'PKR ${user.hourlyRate.toStringAsFixed(0)}/hour',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Menu Items
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: () {},
                      ),
                      _ProfileMenuItem(
                        icon: Icons.work_outline,
                        title: 'My Projects',
                        onTap: () {},
                      ),
                      _ProfileMenuItem(
                        icon: Icons.payment,
                        title: 'Payment Methods',
                        onTap: () {},
                      ),
                      _ProfileMenuItem(
                        icon: Icons.star_outline,
                        title: 'Reviews & Ratings',
                        onTap: () {},
                      ),
                      _ProfileMenuItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () {},
                      ),
                      _ProfileMenuItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
