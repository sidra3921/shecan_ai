import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../constants/app_colors.dart';
import '../models/project_model.dart';
import '../services/supabase_database_service.dart';

class AnalyticsScreen extends StatelessWidget {
  final String userId;
  final String userType;

  const AnalyticsScreen({
    super.key,
    required this.userId,
    required this.userType,
  });

  bool get _isMentor => userType.toLowerCase() == 'mentor';

  @override
  Widget build(BuildContext context) {
    final db = GetIt.instance<SupabaseDatabaseService>();
    final projectStream = _isMentor
        ? db.streamFreelancerProjects(userId)
        : db.streamClientProjects(userId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Analytics')),
      body: StreamBuilder<List<ProjectModel>>(
        stream: projectStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load analytics',
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          final projects = snapshot.data ?? const <ProjectModel>[];
          final completed = projects.where((p) => p.status.toLowerCase() == 'completed').toList();
          final active = projects.where((p) {
            final s = p.status.toLowerCase();
            return s == 'pending' || s == 'in-progress' || s == 'delivered';
          }).toList();

          final totalCount = projects.length;
          final completedCount = completed.length;
          final totalValue = projects.fold<double>(0, (sum, p) => sum + p.budget);
          final completedValue = completed.fold<double>(0, (sum, p) => sum + p.budget);
          final avgBudget = totalCount == 0 ? 0 : totalValue / totalCount;
          final completionRate = totalCount == 0 ? 0 : (completedCount / totalCount) * 100;

          final monthly = _monthlyBuckets(projects);
          final maxMonthly = monthly.isEmpty
              ? 1.0
              : monthly.values.reduce((a, b) => a > b ? a : b);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _metricCard(
                    title: _isMentor ? 'Total Jobs' : 'Total Projects',
                    value: '$totalCount',
                    icon: Icons.work_outline,
                  ),
                  _metricCard(
                    title: 'Completed',
                    value: '$completedCount',
                    icon: Icons.check_circle_outline,
                  ),
                  _metricCard(
                    title: _isMentor ? 'Earnings' : 'Project Value',
                    value: 'Rs ${(_isMentor ? completedValue : totalValue).toStringAsFixed(0)}',
                    icon: Icons.payments_outlined,
                  ),
                  _metricCard(
                    title: 'Completion',
                    value: '${completionRate.toStringAsFixed(0)}%',
                    icon: Icons.insights_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _panel(
                title: 'Pipeline Snapshot',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active: ${active.length}'),
                    const SizedBox(height: 4),
                    Text('Completed: $completedCount'),
                    const SizedBox(height: 4),
                    Text('Average Budget: Rs ${avgBudget.toStringAsFixed(0)}'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _panel(
                title: 'Monthly Activity (Last 6 Months)',
                child: SizedBox(
                  height: 220,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: monthly.entries.map((entry) {
                      final ratio = maxMonthly == 0 ? 0.0 : entry.value / maxMonthly;
                      return _bar(entry.key, ratio, entry.value);
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, double> _monthlyBuckets(List<ProjectModel> projects) {
    final now = DateTime.now();
    final keys = <DateTime>[];
    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      keys.add(d);
    }

    final map = <String, double>{
      for (final k in keys) _monthLabel(k): 0,
    };

    for (final p in projects) {
      final monthKey = DateTime(p.createdAt.year, p.createdAt.month, 1);
      final label = _monthLabel(monthKey);
      if (map.containsKey(label)) {
        map[label] = (map[label] ?? 0) + p.budget;
      }
    }

    return map;
  }

  String _monthLabel(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[d.month - 1];
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return SizedBox(
      width: 165,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _bar(String label, double ratio, double value) {
    final safeRatio = ratio.clamp(0.0, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value == 0 ? '-' : '${(value / 1000).toStringAsFixed(1)}k',
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Container(
          width: 18,
          height: 140 * safeRatio,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
