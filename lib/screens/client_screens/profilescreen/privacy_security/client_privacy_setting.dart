import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text("Privacy Settings"),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Show Profile Public"),
            value: true,
            onChanged: (v) {},
          ),
          SwitchListTile(
            title: const Text("Allow Messages"),
            value: true,
            onChanged: (v) {},
          ),
          SwitchListTile(
            title: const Text("Show Online Status"),
            value: false,
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }
}
