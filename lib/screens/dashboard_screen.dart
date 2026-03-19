import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import 'analytics_screen.dart';
import 'project_management_screen.dart';
import 'user_type_screen.dart';

Future<void> _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  if (!context.mounted) {
    return;
  }

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const UserTypeScreen()),
    (route) => false,
  );
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.trending_up,
                    value: '2,947',
                    label: 'Total Projects',
                    color: AppColors.primary,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.people,
                    value: '1,234',
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
                    icon: Icons.account_balance_wallet,
                    value: 'PKR 254K',
                    label: 'Total Revenue',
                    color: AppColors.success,
                    iconColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star,
                    value: '856',
                    label: 'Top Rated',
                    color: AppColors.warning,
                    iconColor: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // User Growth Chart
            _ChartCard(
              title: 'User Growth Over Time',
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
                          const FlSpot(1, 1.5),
                          const FlSpot(2, 1.4),
                          const FlSpot(3, 2),
                          const FlSpot(4, 2.5),
                          const FlSpot(5, 3),
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
            // Project Completion Chart
            _ChartCard(
              title: 'Project Completion vs Cancellation',
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
                            toY: 3,
                            color: AppColors.success,
                            width: 20,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: 4,
                            color: AppColors.success,
                            width: 20,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: 5,
                            color: AppColors.success,
                            width: 20,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            toY: 6,
                            color: AppColors.success,
                            width: 20,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 4,
                        barRods: [
                          BarChartRodData(
                            toY: 7,
                            color: AppColors.success,
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
            // Top Skills Distribution
            _ChartCard(
              title: 'Top Skills Distribution',
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 30,
                        color: AppColors.primary,
                        title: '',
                        radius: 60,
                      ),
                      PieChartSectionData(
                        value: 25,
                        color: AppColors.info,
                        title: '',
                        radius: 60,
                      ),
                      PieChartSectionData(
                        value: 20,
                        color: AppColors.success,
                        title: '',
                        radius: 60,
                      ),
                      PieChartSectionData(
                        value: 15,
                        color: AppColors.warning,
                        title: '',
                        radius: 60,
                      ),
                      PieChartSectionData(
                        value: 10,
                        color: Colors.purple,
                        title: '',
                        radius: 60,
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Weekly Revenue Chart
            _ChartCard(
              title: 'Weekly Revenue',
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(5, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: (index + 3).toDouble(),
                            color: AppColors.primary,
                            width: 40,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                const Text(
                  'Tech Girl CA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'techgirl@shecan.ai',
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
