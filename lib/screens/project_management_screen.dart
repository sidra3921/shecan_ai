import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Project Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                AppColors.pinkBackground,
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'Project Name',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Client Name',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Start Date',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Budget',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Due Date',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              rows: [
                _buildDataRow(
                  'Logo Design for Barela Salon',
                  'Sarah Khan',
                  'Apr 1, 2025',
                  'PKR 5,000',
                  'Completed',
                  'Apr 15, 2025',
                  AppColors.success,
                ),
                _buildDataRow(
                  'Content Writing for Blog',
                  'Ayesha Ali',
                  'Apr 5, 2025',
                  'PKR 3,000',
                  'In Progress',
                  'Apr 20, 2025',
                  AppColors.info,
                ),
                _buildDataRow(
                  'Social Media Management',
                  'Fatima Ahmed',
                  'Mar 28, 2025',
                  'PKR 10,000',
                  'Completed',
                  'Apr 12, 2025',
                  AppColors.success,
                ),
                _buildDataRow(
                  'Product Photography',
                  'Zainab Malik',
                  'Apr 10, 2025',
                  'PKR 15,000',
                  'Pending',
                  'Apr 25, 2025',
                  AppColors.warning,
                ),
                _buildDataRow(
                  'Website Strategy',
                  'Mariam Hassan',
                  'Mar 25, 2025',
                  'PKR 20,000',
                  'Completed',
                  'Apr 10, 2025',
                  AppColors.success,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(
    String projectName,
    String clientName,
    String startDate,
    String budget,
    String status,
    String dueDate,
    Color statusColor,
  ) {
    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(projectName, style: const TextStyle(fontSize: 13)),
          ),
        ),
        DataCell(Text(clientName, style: const TextStyle(fontSize: 13))),
        DataCell(Text(startDate, style: const TextStyle(fontSize: 13))),
        DataCell(
          Text(
            budget,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
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
        ),
        DataCell(Text(dueDate, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
