import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../user_type_screen.dart';

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Explore People"),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Mentors",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...List.generate(3, (index) => _userCard(context, isMentor: true)),

          const SizedBox(height: 20),

          const Text(
            "Clients",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...List.generate(3, (index) => _userCard(context, isMentor: false)),
        ],
      ),
    );
  }

  // ================= USER CARD =================
  Widget _userCard(BuildContext context, {required bool isMentor}) {
    return GestureDetector(
      onTap: () {
        _showLoginSheet(context, isMentor);
      },

      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.person, color: Colors.white),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMentor ? "Mentor Name" : "Client Name",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        isMentor
                            ? "Flutter Expert"
                            : "Looking for App Developer",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                Icon(Icons.lock, color: AppColors.primary.withOpacity(0.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= LOGIN SHEET =================
  void _showLoginSheet(BuildContext context, bool isMentor) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 40, color: AppColors.primary),

              const SizedBox(height: 10),

              Text(
                "Login Required 🔐",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isMentor
                    ? "Login to view mentor profile and hire"
                    : "Login to view client needs and connect",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // LOGIN BUTTON
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
                      "Login Now",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Maybe Later"),
              ),
            ],
          ),
        );
      },
    );
  }
}
