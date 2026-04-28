import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class LoginActivityScreen extends StatelessWidget {
  const LoginActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text("Login Activity"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.phone_android, color: AppColors.primary),
            title: Text(
              "Samsung Device",
              style: TextStyle(color: AppColors.primary),
            ),
            subtitle: Text("Pakistan • Today"),
          ),
          ListTile(
            leading: Icon(Icons.computer, color: AppColors.primary),
            title: Text(
              "Windows Laptop",
              style: TextStyle(color: AppColors.primary),
            ),
            subtitle: Text("Yesterday"),
          ),
        ],
      ),
    );
  }
}
