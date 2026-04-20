import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../user_type_screen.dart';

class GuestExploreScreen extends StatelessWidget {
  const GuestExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Explore Network"),
        backgroundColor: AppColors.primary,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("🔥 Trending Mentors"),

          const SizedBox(height: 12),

          ...List.generate(5, (i) {
            return _mentorCard(context);
          }),

          const SizedBox(height: 20),

          _sectionTitle("👥 Active Clients"),

          const SizedBox(height: 12),

          ...List.generate(4, (i) {
            return _clientCard(context);
          }),
        ],
      ),
    );
  }

  // ================= MENTOR CARD (CLICKABLE) =================
  Widget _mentorCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPreview(context, "Mentor Profile"),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: const [
            CircleAvatar(radius: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mentor Name",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Flutter Expert",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.lock, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ================= CLIENT CARD (CLICKABLE) =================
  Widget _clientCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPreview(context, "Client Profile"),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: const [
            CircleAvatar(radius: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Client Name",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Looking for Developer",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.lock, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ================= PREVIEW BOTTOM SHEET =================
  void _showPreview(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.visibility_off,
                size: 40,
                color: AppColors.primary,
              ),

              const SizedBox(height: 10),

              Text(
                "$title Locked 🔒",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Login required to view full profile, chat and hire.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserTypeScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Login / Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= TITLE =================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
