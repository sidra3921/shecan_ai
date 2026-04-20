import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../services/supabase_database_service.dart';
import '../../../services/supabase_storage_service.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({
    super.key,
    required this.mentorId,
    this.initialCourse,
  });

  final String mentorId;
  final CourseModel? initialCourse;

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _videoUrlController = TextEditingController();

  String _category = 'Flutter';
  String _level = 'Beginner';
  bool _isSaving = false;

  Uint8List? _thumbnailBytes;
  String _thumbnailExt = 'jpg';
  String _existingThumbnail = '';

  Uint8List? _videoBytes;
  String _videoExt = 'mp4';

  bool get _isEditing => widget.initialCourse != null;

  @override
  void initState() {
    super.initState();
    final course = widget.initialCourse;
    if (course != null) {
      _titleController.text = course.title;
      _descriptionController.text = course.description;
      _priceController.text = course.price.toStringAsFixed(0);
      _durationController.text = course.duration;
      _videoUrlController.text = course.videoUrl;
      _category = course.category;
      _level = course.level;
      _existingThumbnail = course.thumbnailUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final parts = picked.name.split('.');
    final ext = parts.length > 1 ? parts.last.toLowerCase() : 'jpg';

    setState(() {
      _thumbnailExt = ext;
      _thumbnailBytes = null;
    });

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _thumbnailBytes = bytes;
    });
  }

  Future<void> _pickVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final parts = picked.name.split('.');
    final ext = parts.length > 1 ? parts.last.toLowerCase() : 'mp4';

    setState(() {
      _videoExt = ext;
      _videoBytes = null;
    });

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _videoBytes = bytes;
    });
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final db = GetIt.instance<SupabaseDatabaseService>();
    final storage = GetIt.instance<SupabaseStorageService>();

    try {
      final price = double.tryParse(_priceController.text.trim()) ?? 0;
      String courseId;
      String thumbnailUrl = _existingThumbnail;
      String videoUrl = _videoUrlController.text.trim();

      if (_isEditing) {
        courseId = widget.initialCourse!.id;
      } else {
        courseId = await db.createCourse(
          CourseModel(
            id: '',
            mentorId: widget.mentorId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            price: price,
            category: _category,
            duration: _durationController.text.trim(),
            level: _level,
            thumbnailUrl: '',
            videoUrl: videoUrl,
          ),
        );
      }

      if (_thumbnailBytes != null) {
        thumbnailUrl = await storage.uploadCourseThumbnailBytes(
          mentorId: widget.mentorId,
          courseId: courseId,
          bytes: _thumbnailBytes!,
          extension: _thumbnailExt,
        );
      }

      if (_videoBytes != null) {
        videoUrl = await storage.uploadCourseVideoBytes(
          mentorId: widget.mentorId,
          courseId: courseId,
          bytes: _videoBytes!,
          extension: _videoExt,
        );
      }

      await db.updateCourse(courseId, {
        'mentor_id': widget.mentorId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'category': _category,
        'duration': _durationController.text.trim(),
        'thumbnail_url': thumbnailUrl,
        'video_url': videoUrl,
        'level': _level,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Course updated' : 'Course created'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save course: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Course' : 'Add Course'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input(
                controller: _titleController,
                label: 'Course Title',
                hint: 'Flutter Complete Course',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Course title is required'
                    : null,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _descriptionController,
                label: 'Description',
                hint: 'What students will learn',
                minLines: 3,
                maxLines: 5,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _priceController,
                label: 'Price',
                hint: '2000',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = double.tryParse((v ?? '').trim());
                  if (value == null || value <= 0) return 'Enter valid price';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _input(
                controller: _durationController,
                label: 'Duration',
                hint: '10 hours',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Duration is required'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: _decoration('Category'),
                items: const [
                  DropdownMenuItem(value: 'Flutter', child: Text('Flutter')),
                  DropdownMenuItem(value: 'UI/UX', child: Text('UI/UX')),
                  DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                  DropdownMenuItem(value: 'Design', child: Text('Design')),
                  DropdownMenuItem(value: 'Career', child: Text('Career')),
                ],
                onChanged: (value) => setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _level,
                decoration: _decoration('Level'),
                items: const [
                  DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                  DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                ],
                onChanged: (value) => setState(() => _level = value ?? _level),
              ),
              const SizedBox(height: 12),
              _input(
                controller: _videoUrlController,
                label: 'Video URL',
                hint: 'https://... (optional if you upload video)',
              ),
              const SizedBox(height: 12),
              _uploadTile(
                title: 'Thumbnail Image',
                subtitle: _thumbnailBytes != null
                    ? 'Selected image'
                    : (_existingThumbnail.isNotEmpty ? 'Current thumbnail exists' : 'Tap to upload'),
                icon: Icons.image_outlined,
                onTap: _pickThumbnail,
              ),
              const SizedBox(height: 10),
              _uploadTile(
                title: 'Course Video',
                subtitle: _videoBytes != null
                    ? 'Selected video file'
                    : 'Tap to upload MP4/video file',
                icon: Icons.video_library_outlined,
                onTap: _pickVideo,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveCourse,
                  child: Text(_isSaving ? 'Saving...' : (_isEditing ? 'Update Course' : 'Publish Course')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _decoration(label).copyWith(hintText: hint),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _uploadTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surface),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.upload_file),
          ],
        ),
      ),
    );
  }
}
