import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/app_colors.dart';
import '../../../models/project_model.dart';
import '../../../services/supabase_database_service.dart';
import 'women_order_workflow_detail_screen.dart';

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
  final String userId;

  const MentorOrdersScreen({super.key, required this.userId});

  String _humanStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = GetIt.instance<SupabaseDatabaseService>();

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<List<ProjectModel>>(
        stream: db.streamFreelancerProjects(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load orders',
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          final all = snapshot.data ?? const <ProjectModel>[];
          final active = all.where((p) {
            final s = p.status.toLowerCase();
            return s != 'completed' && s != 'cancelled';
          }).toList();
          final completed = all.where((p) => p.status.toLowerCase() == 'completed').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionTitle(title: '🔥 Active Orders'),
              const SizedBox(height: 10),
              if (active.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('No active orders'),
                ),
              ...active.map((project) => _orderTile(context, project, true)),
              const SizedBox(height: 20),
              _SectionTitle(title: '✅ Completed Orders'),
              const SizedBox(height: 10),
              if (completed.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('No completed orders'),
                ),
              ...completed.map((project) => _orderTile(context, project, false)),
            ],
          );
        },
      ),
    );
  }

  Widget _orderTile(BuildContext context, ProjectModel project, bool isActive) {
    final progress = (project.progress.clamp(0, 100)) / 100;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MentorOrderWorkflowDetailScreen(
              userId: userId,
              projectId: project.id,
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.warning.withValues(alpha: 0.2)
                        : AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _humanStatus(project.status),
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Price: Rs ${project.budget.toStringAsFixed(0)}'),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              color: AppColors.primary,
              minHeight: 6,
            ),
            const SizedBox(height: 5),
            Text('${(progress * 100).toInt()}% completed'),
          ],
        ),
      ),
    );
  }
}
