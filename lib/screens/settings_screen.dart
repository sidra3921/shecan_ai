import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import 'user_type_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const UserTypeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Settings
          const Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Email Preferences',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Notifications
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _SwitchTile(
                  icon: Icons.email,
                  title: 'Email Notifications',
                  subtitle: 'Receive updates via email',
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                ),
                const Divider(height: 1),
                _SwitchTile(
                  icon: Icons.notifications,
                  title: 'Push Notifications',
                  subtitle: 'Receive push notifications',
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                ),
                const Divider(height: 1),
                _SwitchTile(
                  icon: Icons.sms,
                  title: 'SMS Notifications',
                  subtitle: 'Receive updates via SMS',
                  value: _smsNotifications,
                  onChanged: (value) {
                    setState(() {
                      _smsNotifications = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Privacy & Security
          const Text(
            'Privacy & Security',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.security,
                  title: 'Privacy Settings',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.verified_user,
                  title: 'Two-Factor Authentication',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.block,
                  title: 'Blocked Users',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Support
          const Text(
            'Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About SheCan AI',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}
