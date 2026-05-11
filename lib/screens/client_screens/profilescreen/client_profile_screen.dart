import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../services/supabase_database_service.dart';
import '../../../services/supabase_auth_service.dart';
import '../../edit_profile_screen.dart';
import 'help_center/client_help_center_screen.dart';
import 'order_history/client_order_history.dart';
import 'payment_method/client_payment.dart';
import 'privacy_security/client_privacy_and_security.dart';
import 'save_women/client_save_women.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final db = GetIt.instance<SupabaseDatabaseService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text("Profile"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<UserModel?>(
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

            return Column(
              children: [
                //  PROFILE HEADER
                _buildHeader(context, user),

                const SizedBox(height: 20),

                //  STATS
                Row(
                  children: [
                    _statCard('Projects', '${user.completedProjects}'),
                    _statCard('Reviews', '${user.totalReviews}'),
                    _statCard('Rating', user.rating.toStringAsFixed(1)),
                  ],
                ),

                const SizedBox(height: 20),

                //  SETTINGS
                _settingTile(
                  context,
                  Icons.payment,
                  'Payment Methods',
                  const PaymentMethodsScreen(),
                ),
                _settingTile(
                  context,
                  Icons.history,
                  'Order History',
                  const OrderHistoryScreen(),
                ),
                _settingTile(
                  context,
                  Icons.favorite,
                  'Saved Mentors',
                  SavedMentorsScreen(userId: userId),
                ),
                _settingTile(
                  context,
                  Icons.security,
                  'Privacy & Security',
                  const PrivacySecurityScreen(),
                ),
                _settingTile(
                  context,
                  Icons.help,
                  'Help Center',
                  const HelpCenterScreen(),
                ),

                const SizedBox(height: 20),

                //  LOGOUT
                InkWell(
                  onTap: () async {
                    await SupabaseAuthService().signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  //  HEADER
  Widget _buildHeader(BuildContext context, UserModel user) {
    final hasPhoto = user.photoURL.trim().isNotEmpty;

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
                  '${user.userType} • ${user.email}',
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
            child: const Text(
              "Edit",
              style: TextStyle(color: AppColors.background),
            ),
          ),
        ],
      ),
    );
  }

  // 📊 STATS
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

  // ⚙️ CLICKABLE TILE
  Widget _settingTile(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
