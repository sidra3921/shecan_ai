import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "Ongoing"),
            Tab(text: "Completed"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: const [
          OrdersList(isCompleted: false),
          OrdersList(isCompleted: true),
        ],
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final bool isCompleted;

  const OrdersList({super.key, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return OrderCard(isCompleted: isCompleted);
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final bool isCompleted;

  const OrderCard({super.key, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Title + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Logo Design Project",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? "Completed" : "In Progress",
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 👤 Mentor Info
          Row(
            children: const [
              CircleAvatar(radius: 20),
              SizedBox(width: 10),
              Text(
                "Ayesha Khan",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 📊 Progress Bar
          if (!isCompleted)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Progress", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: 0.6,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                ),
              ],
            ),

          const SizedBox(height: 12),

          // 💰 Price + Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "\$50",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              isCompleted
                  ? TextButton(onPressed: () {}, child: const Text("Review"))
                  : ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text("View"),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
