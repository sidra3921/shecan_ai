import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';

class OrderDetailScreen extends StatelessWidget {
  final String title;
  final String status;
  final int progress;
  final int total;
  final int paid;

  const OrderDetailScreen({
    super.key,
    required this.title,
    required this.status,
    required this.progress,
    required this.total,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // STATUS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: status == "Completed"
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(status),
            ),

            const SizedBox(height: 20),

            // PROGRESS
            const Text("Progress"),
            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: progress / 100,
              color: AppColors.primary,
              backgroundColor: Colors.grey.shade200,
            ),

            const SizedBox(height: 10),

            Text("$progress% Completed"),

            const SizedBox(height: 30),

            // PAYMENT BREAKDOWN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _row("Total Amount", "RS $total"),
                  const SizedBox(height: 10),
                  _row("Paid Amount", "RS $paid"),
                  const SizedBox(height: 10),
                  _row("Remaining", "RS ${total - paid}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String a, String b) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a),
        Text(b, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
