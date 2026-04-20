import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/app_colors.dart';
import '../../../models/project_model.dart';
import '../../../services/supabase_database_service.dart';
import 'client_order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.userId});

  final String userId;

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
        children: [
          OrdersList(userId: widget.userId, isCompleted: false),
          OrdersList(userId: widget.userId, isCompleted: true),
        ],
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final String userId;
  final bool isCompleted;

  const OrdersList({
    super.key,
    required this.userId,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final db = GetIt.instance<SupabaseDatabaseService>();

    return StreamBuilder<List<ProjectModel>>(
      stream: db.streamClientProjects(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load projects',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }

        final projects = snapshot.data ?? const <ProjectModel>[];
        final filtered = projects.where((project) {
          final status = project.status.toLowerCase();
          if (isCompleted) return status == 'completed';
          return status != 'completed' && status != 'cancelled';
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              isCompleted
                  ? 'No completed orders yet'
                  : 'No ongoing orders yet',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return OrderCard(project: filtered[index], currentUserId: userId);
          },
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final ProjectModel project;
  final String currentUserId;

  const OrderCard({
    super.key,
    required this.project,
    required this.currentUserId,
  });

  String _humanStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = project.status.toLowerCase() == 'completed';

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
              Expanded(
                child: Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _humanStatus(project.status),
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
            children: [
              CircleAvatar(radius: 20),
              SizedBox(width: 10),
              Text(
                project.category ?? 'Project',
                style: const TextStyle(color: AppColors.textSecondary),
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
                  value: (project.progress.clamp(0, 100)) / 100,
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
              Text(
                '\$${project.budget.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              isCompleted
                  ? TextButton(onPressed: () {}, child: const Text("Review"))
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClientOrderDetailScreen(
                              userId: currentUserId,
                              projectId: project.id,
                            ),
                          ),
                        );
                      },
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
