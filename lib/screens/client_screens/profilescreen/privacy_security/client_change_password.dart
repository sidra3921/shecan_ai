import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(hintText: "Old Password"),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(hintText: "New Password"),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(hintText: "Confirm Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }
}
