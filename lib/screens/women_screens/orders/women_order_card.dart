import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import 'women_order_detail.dart';

class OrderCard extends StatelessWidget {
  final String title;
  final String client;
  final String price;
  final double progress;
  final String status;
  final bool isActive;

  const OrderCard({
    super.key,
    required this.title,
    required this.client,
    required this.price,
    required this.progress,
    required this.status,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(
              title: title,
              client: client,
              price: price,
              progress: progress,
              status: status,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.warning.withValues(alpha: 0.2)
                        : AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "Client: $client",
              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 6),

            Text(
              "Price: $price",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            // Progress
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              color: AppColors.primary,
              minHeight: 6,
            ),

            const SizedBox(height: 5),

            Text("${(progress * 100).toInt()}% completed"),
          ],
        ),
      ),
    );
  }
}
