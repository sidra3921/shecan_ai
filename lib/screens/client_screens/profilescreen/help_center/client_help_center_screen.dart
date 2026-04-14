import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Help Center"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "How can we help you?",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            _tile("FAQs"),
            _tile("Contact Support"),
            _tile("Report a Problem"),
          ],
        ),
      ),
    );
  }

  Widget _tile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.help, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
    );
  }
}
