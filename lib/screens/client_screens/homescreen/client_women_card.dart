import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class WomenCard extends StatelessWidget {
  const WomenCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 25),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mentor Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Flutter Developer"),
              ],
            ),
          ),

          const Text("\$20"),
        ],
      ),
    );
  }
}
