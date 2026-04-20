import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../services/supabase_database_service.dart';

class ClientCourseDetailScreen extends StatefulWidget {
  const ClientCourseDetailScreen({
    super.key,
    required this.course,
    this.currentUserId,
  });

  final CourseModel course;
  final String? currentUserId;

  @override
  State<ClientCourseDetailScreen> createState() => _ClientCourseDetailScreenState();
}

class _ClientCourseDetailScreenState extends State<ClientCourseDetailScreen> {
  bool _isEnrolling = false;

  Future<void> _enrollNow() async {
    final clientId = widget.currentUserId;
    if (clientId == null || clientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login required to enroll in this course.')),
      );
      return;
    }

    final db = GetIt.instance<SupabaseDatabaseService>();

    final alreadyEnrolled = await db.isClientEnrolled(
      courseId: widget.course.id,
      clientId: clientId,
    );
    if (alreadyEnrolled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are already enrolled in this course.')),
      );
      return;
    }

    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Course Purchase'),
        content: Text(
          'Proceed to enroll in "${widget.course.title}" for Rs ${widget.course.price.toStringAsFixed(0)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enroll Now'),
          ),
        ],
      ),
    );

    if (approved != true) return;

    setState(() => _isEnrolling = true);

    try {
      await db.enrollInCourse(
        courseId: widget.course.id,
        clientId: clientId,
        mentorId: widget.course.mentorId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enrollment successful. Added to My Learning.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not enroll: $e')),
      );
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Course Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: course.thumbnailUrl.isNotEmpty
                ? Image.network(
                    course.thumbnailUrl,
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 210,
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  )
                : Container(
                    height: 210,
                    color: AppColors.surface,
                    alignment: Alignment.center,
                    child: const Icon(Icons.school_outlined, size: 44),
                  ),
          ),
          const SizedBox(height: 14),
          Text(
            course.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(course.category),
              _chip(course.level),
              _chip(course.duration),
              _chip('Rating ${course.rating.toStringAsFixed(1)}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(course.description),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Video Preview',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  course.videoUrl.isNotEmpty
                      ? course.videoUrl
                      : 'Video URL will appear here once mentor uploads content.',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
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
                child: Text(
                  'Rs ${course.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isEnrolling ? null : _enrollNow,
                  child: Text(_isEnrolling ? 'Enrolling...' : 'Enroll Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
