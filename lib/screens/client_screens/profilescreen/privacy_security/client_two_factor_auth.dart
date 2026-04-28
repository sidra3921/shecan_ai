import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class TwoFactorScreen extends StatelessWidget {
  const TwoFactorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text("Two Factor Auth"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text("Enable 2FA for extra security"),

          SwitchListTile(
            title: const Text("Enable 2FA"),
            value: true,
            onChanged: (v) {},
          ),

          const Text("Verification method: SMS / Email"),
        ],
      ),
    );
  }
}
