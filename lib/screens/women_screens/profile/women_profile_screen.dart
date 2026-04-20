import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../services/supabase_database_service.dart';
import '../../../services/supabase_auth_service.dart';
import '../../edit_profile_screen.dart';

class MentorProfileScreen extends StatelessWidget {
  const MentorProfileScreen({super.key, required this.userId});

  final String userId;

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Settings",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              _tile(Icons.security, "Privacy & Security"),
              _tile(Icons.lock, "Change Password"),
              _tile(Icons.history, "Login Activity"),
              _tile(Icons.help, "Help & Support"),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    await SupabaseAuthService().signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: const Text("Logout"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _tile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = GetIt.instance<SupabaseDatabaseService>();

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Mentor Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),

      body: StreamBuilder<UserModel?>(
        stream: db.streamUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load profile',
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Profile not found'));
          }

          final hasPhoto = user.photoURL.trim().isNotEmpty;
          final headline = user.skills.isNotEmpty
              ? user.skills.take(3).join(' • ')
              : user.hourlyRate > 0
              ? 'Hourly rate: Rs ${user.hourlyRate.toStringAsFixed(0)}'
              : 'Mentor';
          final about = user.bio.trim().isNotEmpty
              ? user.bio.trim()
              : 'Update your bio from Edit Profile to tell clients about your experience.';
          final skillTags = user.skills.isNotEmpty
              ? user.skills
              : const ['Mentor'];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(context, user, hasPhoto, headline),

              const SizedBox(height: 16),

              Row(
                children: [
                  _statCard('Projects', '${user.completedProjects}'),
                  _statCard('Rating', user.rating.toStringAsFixed(1)),
                  _statCard('Reviews', '${user.totalReviews}'),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                'Skills',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skillTags.map(_chip).toList(),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  about,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    UserModel user,
    bool hasPhoto,
    String headline,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: hasPhoto ? NetworkImage(user.photoURL) : null,
            child: hasPhoto
                ? null
                : const Icon(Icons.person, size: 35, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  headline,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // 🧠 CHIP
  static Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.primary, fontSize: 12),
      ),
    );
  }
}
