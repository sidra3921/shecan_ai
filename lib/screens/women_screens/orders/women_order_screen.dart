import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import 'women_order_card.dart';

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class MentorOrdersScreen extends StatelessWidget {
  const MentorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: "🔥 Active Orders"),
          const SizedBox(height: 10),

          OrderCard(
            title: "Flutter E-commerce App",
            client: "Ali Ahmed",
            price: "RS 12,000",
            progress: 0.65,
            status: "In Progress",
            isActive: true,
          ),

          OrderCard(
            title: "UI Design Fixes",
            client: "Sara Khan",
            price: "RS 5,000",
            progress: 0.30,
            status: "In Progress",
            isActive: true,
          ),

          const SizedBox(height: 20),

          _SectionTitle(title: "✅ Completed Orders"),
          const SizedBox(height: 10),

          OrderCard(
            title: "Portfolio Website",
            client: "Hassan",
            price: "RS 8,000",
            progress: 1.0,
            status: "Completed",
            isActive: false,
          ),

          OrderCard(
            title: "Landing Page Design",
            client: "Ayesha",
            price: "RS 4,500",
            progress: 1.0,
            status: "Completed",
            isActive: false,
          ),
        ],
      ),
    );
  }
}
