import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import 'client_view_women_profile.dart';

class SavedMentorsScreen extends StatelessWidget {
  const SavedMentorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Saved Mentors"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(5, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.person, color: Colors.white),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mentor Name",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Flutter Expert",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // 👇 VIEW BUTTON NAVIGATION
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MentorProfileScreen(
                          name: "Mentor Name",
                          skill: "Flutter Expert",
                        ),
                      ),
                    );
                  },
                  child: const Text("View"),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
