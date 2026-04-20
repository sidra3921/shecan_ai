import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class OrderDetailScreen extends StatelessWidget {
  final String title;
  final String client;
  final String price;
  final double progress;
  final String status;

  const OrderDetailScreen({
    super.key,
    required this.title,
    required this.client,
    required this.price,
    required this.progress,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Order Details"),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text("Client: $client"),
                  Text("Price: $price"),
                  Text("Status: $status"),

                  const SizedBox(height: 20),

                  LinearProgressIndicator(
                    value: progress,
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: 10),
                  Text("Progress: ${(progress * 100).toInt()}%"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                    ),
                    onPressed: () {},
                    child: const Text("Mark Complete"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                    ),
                    onPressed: () {},
                    child: const Text("Message Client"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
