import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../models/course_enrollment_model.dart';
import '../../../services/chat_service.dart';
import '../../../services/supabase_database_service.dart';
import '../chatscreen/client_detail_chat_screen.dart';

class ClientLearningPlayerScreen extends StatefulWidget {
  const ClientLearningPlayerScreen({
    super.key,
    required this.course,
    required this.enrollment,
    required this.clientId,
  });

  final CourseModel course;
  final CourseEnrollmentModel enrollment;
  final String clientId;

  @override
  State<ClientLearningPlayerScreen> createState() => _ClientLearningPlayerScreenState();
}

class _ClientLearningPlayerScreenState extends State<ClientLearningPlayerScreen> {
  static const int _moduleCount = 5;

  Future<void> _markProgress() async {
    final next = (widget.enrollment.progressPercent + 20).clamp(0, 100);
    try {
      await GetIt.instance<SupabaseDatabaseService>().updateEnrollmentProgress(
        enrollmentId: widget.enrollment.id,
        progressPercent: next.toDouble(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Progress updated to ${next.toStringAsFixed(0)}%')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update progress: $e')),
      );
    }
  }

  Future<void> _askInstructor() async {
    final db = GetIt.instance<SupabaseDatabaseService>();
    final chatService = GetIt.instance<ChatService>();

    final mentor = await db.getUser(widget.course.mentorId);
    if (mentor == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instructor not found')),
      );
      return;
    }

    final authUser = Supabase.instance.client.auth.currentUser;
    final currentName = authUser?.userMetadata?['display_name']?.toString().trim();

    final conversation = await chatService.getOrCreateDirectConversation(
      currentUserId: widget.clientId,
      currentUserName: (currentName == null || currentName.isEmpty)
          ? (authUser?.email?.split('@').first ?? 'Client')
          : currentName,
      otherUser: mentor,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          title: mentor.displayName,
          isAI: false,
          currentUserId: widget.clientId,
          conversation: conversation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.enrollment.progressPercent.clamp(0, 100);
    final completedModules = ((progress / 100) * _moduleCount).floor();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.course.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Video Player',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill, size: 44, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        widget.course.videoUrl.isNotEmpty
                            ? 'Tap to play course video'
                            : 'Video will be available soon',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Progress: ${progress.toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress / 100,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  minHeight: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Modules',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...List.generate(_moduleCount, (index) {
                  final moduleIndex = index + 1;
                  final done = moduleIndex <= completedModules;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      done ? Icons.check_circle : Icons.play_circle_outline,
                      color: done ? AppColors.success : AppColors.textSecondary,
                    ),
                    title: Text('Module $moduleIndex'),
                    subtitle: Text(done ? 'Completed' : 'Pending'),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _askInstructor,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Ask Instructor'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _markProgress,
                  child: const Text('Mark Next Module'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
