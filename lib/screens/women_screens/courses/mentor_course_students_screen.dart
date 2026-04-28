import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/app_colors.dart';
import '../../../services/supabase_database_service.dart';

class MentorCourseStudentsScreen extends StatelessWidget {
  const MentorCourseStudentsScreen({super.key, required this.mentorId});

  final String mentorId;

  @override
  Widget build(BuildContext context) {
    final db = GetIt.instance<SupabaseDatabaseService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text('Course Students'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.streamMentorCourseStudents(mentorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load students',
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const Center(child: Text('No enrollments yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final progress = ((item['progress_percent'] ?? 0) as num)
                  .toDouble();
              final studentName = (item['student_name'] ?? 'Student')
                  .toString();
              final courseTitle = (item['course_title'] ?? 'Course').toString();
              final email = (item['student_email'] ?? '').toString();
              final photoUrl = (item['student_photo_url'] ?? '').toString();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.surface,
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            courseTitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (email.isNotEmpty)
                            Text(
                              email,
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (progress.clamp(0, 100)) / 100,
                            color: AppColors.primary,
                            backgroundColor: AppColors.surface,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${progress.toStringAsFixed(0)}% progress',
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
              );
            },
          );
        },
      ),
    );
  }
}
