import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class GuestMentorProfile extends StatelessWidget {
  const GuestMentorProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Mentor Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 40),
            const SizedBox(height: 10),
            const Text("Mentor Name"),
            const Text("Flutter Expert"),

            const SizedBox(height: 20),

            const Text(
              "Highly skilled mentor with multiple projects experience...",
            ),

            const Spacer(),

            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "Login to Hire",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
