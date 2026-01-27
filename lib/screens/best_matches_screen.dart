import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BestMatchesScreen extends StatelessWidget {
  const BestMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Best Matches'),
            Text(
              'Find a PICO Match for your Project',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TalentCard(
            name: 'Amina Khan',
            title: 'UI/UX Designer',
            skills: ['Adobe XD', 'Figma', 'Sketch'],
            rating: 4.9,
            hourlyRate: 'PKR 2000/hr',
            completedProjects: 47,
            imageIcon: Icons.person,
          ),
          _TalentCard(
            name: 'Fatima Ahmed',
            title: 'Content Writer',
            skills: ['SEO Writing', 'Copywriting', 'Blog Posts'],
            rating: 4.8,
            hourlyRate: 'PKR 1500/hr',
            completedProjects: 32,
            imageIcon: Icons.person,
          ),
          _TalentCard(
            name: 'Sara Malik',
            title: 'Digital Marketer',
            skills: ['Social Media', 'Google Ads', 'Analytics'],
            rating: 4.7,
            hourlyRate: 'PKR 2500/hr',
            completedProjects: 28,
            imageIcon: Icons.person,
          ),
          _TalentCard(
            name: 'Zainab Ali',
            title: 'Graphic Designer',
            skills: ['Logo Design', 'Branding', 'Illustration'],
            rating: 4.9,
            hourlyRate: 'PKR 1800/hr',
            completedProjects: 54,
            imageIcon: Icons.person,
          ),
        ],
      ),
    );
  }
}

class _TalentCard extends StatelessWidget {
  final String name;
  final String title;
  final List<String> skills;
  final double rating;
  final String hourlyRate;
  final int completedProjects;
  final IconData imageIcon;

  const _TalentCard({
    required this.name,
    required this.title,
    required this.skills,
    required this.rating,
    required this.hourlyRate,
    required this.completedProjects,
    required this.imageIcon,
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
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.pinkBackground,
                  child: Icon(imageIcon, size: 30, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$completedProjects projects',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map(
                    (skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.success, width: 1),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hourly Rate',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hourlyRate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Invite'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
