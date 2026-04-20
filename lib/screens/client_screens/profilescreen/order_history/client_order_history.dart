import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import 'client_order_detail.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _orderCard(context, "Flutter Coaching", "Completed", 100, 5000, 5000),
          _orderCard(context, "UI Design Help", "Active", 60, 5000, 3000),
          _orderCard(context, "Logo Design", "Active", 30, 2000, 600),
        ],
      ),
    );
  }

  Widget _orderCard(
    BuildContext context,
    String title,
    String status,
    int progress,
    int total,
    int paid,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(
              title: title,
              status: status,
              progress: progress,
              total: total,
              paid: paid,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == "Completed"
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Progress Bar
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primary,
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Paid: RS $paid"), Text("Total: RS $total")],
            ),
          ],
        ),
      ),
    );
  }
}
