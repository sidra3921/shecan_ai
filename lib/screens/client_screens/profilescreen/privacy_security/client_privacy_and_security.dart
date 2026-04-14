import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import 'client_change_password.dart';
import 'client_login_activity.dart';
import 'client_privacy_setting.dart';
import 'client_two_factor_auth.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Privacy & Security"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Column(
        children: [
          _tile(context, "Change Password", const ChangePasswordScreen()),
          _tile(context, "Two-Factor Authentication", const TwoFactorScreen()),
          _tile(context, "Login Activity", const LoginActivityScreen()),
          _tile(context, "Privacy Settings", const PrivacySettingsScreen()),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String title, Widget screen) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
