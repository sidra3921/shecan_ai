import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/app_colors.dart';
import '../../../models/enrolled_course_item_model.dart';
import '../../../services/supabase_database_service.dart';
import 'client_learning_player_screen.dart';

class ClientMyLearningScreen extends StatelessWidget {
  const ClientMyLearningScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final db = GetIt.instance<SupabaseDatabaseService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Learning')),
      body: StreamBuilder<List<EnrolledCourseItemModel>>(
        stream: db.streamClientEnrolledCourses(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load enrolled courses',
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          final items = snapshot.data ?? const <EnrolledCourseItemModel>[];
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No courses enrolled yet. Explore courses and start learning.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final progress = item.enrollment.progressPercent.clamp(0, 100);

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientLearningPlayerScreen(
                        course: item.course,
                        enrollment: item.enrollment,
                        clientId: userId,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item.course.thumbnailUrl.isNotEmpty
                            ? Image.network(
                                item.course.thumbnailUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 72,
                                  height: 72,
                                  color: AppColors.surface,
                                  child: const Icon(Icons.school_outlined),
                                ),
                              )
                            : Container(
                                width: 72,
                                height: 72,
                                color: AppColors.surface,
                                child: const Icon(Icons.school_outlined),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.course.title,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.course.level} • ${item.course.duration}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress / 100,
                              color: AppColors.primary,
                              backgroundColor: AppColors.surface,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${progress.toStringAsFixed(0)}% completed',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
