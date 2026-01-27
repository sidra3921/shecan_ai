import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DisputesScreen extends StatelessWidget {
  const DisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Disputes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DisputeCard(
            disputeId: '#D001',
            title: 'Payment not received',
            projectName: 'Logo Design for Barela Salon',
            client: 'Sarah Khan',
            status: 'Open',
            statusColor: AppColors.error,
            date: 'Jan 20, 2026',
            description:
                'The client has not released the payment even after project completion.',
          ),
          _DisputeCard(
            disputeId: '#D002',
            title: 'Scope creep issue',
            projectName: 'Website Development',
            client: 'Ayesha Ali',
            status: 'In Progress',
            statusColor: AppColors.warning,
            date: 'Jan 18, 2026',
            description:
                'Client is requesting additional features not mentioned in the original scope.',
          ),
          _DisputeCard(
            disputeId: '#D003',
            title: 'Quality concerns',
            projectName: 'Content Writing',
            client: 'Fatima Ahmed',
            status: 'Resolved',
            statusColor: AppColors.success,
            date: 'Jan 15, 2026',
            description:
                'Client raised concerns about content quality. Issue has been resolved.',
          ),
        ],
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final String disputeId;
  final String title;
  final String projectName;
  final String client;
  final String status;
  final Color statusColor;
  final String date;
  final String description;

  const _DisputeCard({
    required this.disputeId,
    required this.title,
    required this.projectName,
    required this.client,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    disputeId,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.work_outline,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    projectName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Client: $client',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Take Action'),
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
