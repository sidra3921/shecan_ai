import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fl_chart/fl_chart.dart';

import '../constants/app_colors.dart';
import '../services/supabase_auth_service.dart';
import 'analytics_screen.dart';
import 'project_management_screen.dart';
import 'user_type_screen.dart';

Future<void> _logout(BuildContext context) async {
    await GetIt.I<SupabaseAuthService>().signOut();
  if (!context.mounted) {
    return;
  }

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const UserTypeScreen()),
    (route) => false,
  );
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = _getDashboardStats();
    });
  }

  Future<Map<String, dynamic>> _getDashboardStats() async {
    return {
      'totalProjects': 0,
      'activeProjects': 0,
      'completedProjects': 0,
      'totalEarnings': 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
        ],
      ),
      drawer: _buildDrawer(context),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStats,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = snapshot.data ?? {};
          final totalUsers = stats['totalUsers'] ?? 0;
          final totalProjects = stats['totalProjects'] ?? 0;
          final completedProjects = stats['completedProjects'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards with Real Data
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up,
                        value: totalProjects.toString(),
                        label: 'Total Projects',
                        color: AppColors.primary,
                        iconColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people,
                        value: totalUsers.toString(),
                        label: 'Total Users',
                        color: AppColors.info,
                        iconColor: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        value: completedProjects.toString(),
                        label: 'Completed',
                        color: AppColors.success,
                        iconColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star,
                        value:
                            '${((completedProjects / (totalProjects > 0 ? totalProjects : 1)) * 100).toStringAsFixed(0)}%',
                        label: 'Success Rate',
                        color: AppColors.warning,
                        iconColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (totalProjects == 0 && totalUsers == 0)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        Icon(
                          Icons.dashboard,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No data yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start creating projects to see analytics',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // User Growth Chart
                  _ChartCard(
                    title: 'Project Completion Rate',
                    child: SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                const FlSpot(0, 1),
                                FlSpot(1, completedProjects > 0 ? 1.5 : 1),
                                FlSpot(2, completedProjects > 0 ? 1.4 : 1),
                                FlSpot(3, completedProjects > 0 ? 2 : 1),
                                FlSpot(4, completedProjects > 0 ? 2.5 : 1),
                                FlSpot(5, completedProjects.toDouble()),
                              ],
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Project Status Distribution
                  _ChartCard(
                    title: 'Project Status Overview',
                    child: SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: completedProjects.toDouble(),
                                  color: AppColors.success,
                                  width: 20,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: (totalProjects - completedProjects)
                                      .toDouble(),
                                  color: AppColors.warning,
                                  width: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Platform Summary
                  _ChartCard(
                    title: 'Platform Summary',
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Active Users',
                            value: totalUsers.toString(),
                            icon: Icons.people,
                            color: AppColors.info,
                          ),
                          const Divider(height: 24),
                          _SummaryRow(
                            label: 'Total Projects',
                            value: totalProjects.toString(),
                            icon: Icons.work,
                            color: AppColors.primary,
                          ),
                          const Divider(height: 24),
                          _SummaryRow(
                            label: 'Completed Projects',
                            value: completedProjects.toString(),
                            icon: Icons.check_circle,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  GetIt.I<SupabaseAuthService>().currentUser?.userMetadata?['display_name'] as String? ?? 'SheCan User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  GetIt.I<SupabaseAuthService>().currentUser?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => Navigator.pop(context),
          ),
          _DrawerItem(
            icon: Icons.work,
            title: 'Projects',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _DrawerItem(
            icon: Icons.analytics,
            title: 'Analytics',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
          ),
          _DrawerItem(
            icon: Icons.table_chart,
            title: 'Project Management',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectManagementScreen(),
                ),
              );
            },
          ),
          const Divider(),
          _DrawerItem(icon: Icons.settings, title: 'Settings', onTap: () {}),
          _DrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: onTap,
    );
  }
}
