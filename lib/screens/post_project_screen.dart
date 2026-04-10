import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../constants/app_colors.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_database_service.dart';
import '../models/project_model.dart';

class PostProjectScreen extends StatefulWidget {
  const PostProjectScreen({super.key});

  @override
  State<PostProjectScreen> createState() => _PostProjectScreenState();
}

class _PostProjectScreenState extends State<PostProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _selectedSkills = <String>[];
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  final List<String> _availableSkills = [
    'Flutter',
    'Dart',
    'Firebase',
    'UI/UX Design',
    'Mobile Development',
    'Web Development',
    'Backend',
    'Database',
    'API Integration',
    'Testing',
  ];

  Future<void> _postProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = SupabaseAuthService();
      final databaseService = GetIt.I<SupabaseDatabaseService>();
      final userId = authService.currentUserId!;

      final project = ProjectModel(
        id: '', // Firestore will generate
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        budget: double.parse(_budgetController.text.trim()),
        deadline: _selectedDeadline,
        clientId: userId,
        skills: _selectedSkills,
        status: 'pending',
      );

      await databaseService.createProject(project);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post project: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post a New Project'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Project Title
                  const Text(
                    'Project Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Logo Design for Beauty Salon',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter project name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Project Description
                  const Text(
                    'Project Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Describe your project in detail...',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter project description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Category
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      hintText: 'Select category',
                    ),
                    items:
                        [
                              'Design',
                              'Development',
                              'Writing',
                              'Marketing',
                              'Photography',
                            ]
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 20),
                  // Budget
                  const Text(
                    'Budget',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter budget in PKR',
                      prefixText: 'PKR ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter budget';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Duration
                  const Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      hintText: 'Select duration',
                    ),
                    items:
                        [
                              'Less than 1 week',
                              '1-2 weeks',
                              '2-4 weeks',
                              '1-3 months',
                              'More than 3 months',
                            ]
                            .map(
                              (duration) => DropdownMenuItem(
                                value: duration,
                                child: Text(duration),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 30),
                  // Post Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _postProject,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Post Project'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
