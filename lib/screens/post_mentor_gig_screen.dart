import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../constants/app_colors.dart';
import '../models/mentor_gig_model.dart';
import '../services/recommendation_service.dart';
import '../services/supabase_auth_service.dart';

class PostMentorGigScreen extends StatefulWidget {
  const PostMentorGigScreen({super.key});

  @override
  State<PostMentorGigScreen> createState() => _PostMentorGigScreenState();
}

class _PostMentorGigScreenState extends State<PostMentorGigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicheController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  final _availableSkills = const [
    'Logo Design',
    'UI/UX',
    'Flutter',
    'Web Development',
    'Content Writing',
    'Digital Marketing',
    'SEO',
    'Social Media',
    'Photography',
    'Video Editing',
  ];

  final _selectedSkills = <String>[];
  bool _isGenerating = false;
  bool _isSaving = false;

  Future<void> _generateWithAI() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final recommendationService = GetIt.I<RecommendationService>();
      final draft = recommendationService.generateMentorGigDraft(
        niche: _nicheController.text.trim(),
        selectedSkills: _selectedSkills,
      );

      if (!mounted) return;
      setState(() {
        _titleController.text = draft.title;
        _descriptionController.text = draft.description;
        if (_selectedSkills.isEmpty) {
          _selectedSkills.addAll(draft.suggestedSkills);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI draft generated. Review and publish.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate AI draft')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _publishGig() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one skill')),
      );
      return;
    }

    final authService = GetIt.I<SupabaseAuthService>();
    final userId = authService.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again')), 
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final gig = MentorGigModel(
        id: '',
        mentorId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        skills: _selectedSkills,
        hourlyRate: double.tryParse(_hourlyRateController.text.trim()) ?? 0,
        isActive: true,
      );

      await GetIt.I<RecommendationService>().createMentorGig(gig);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mentor gig published successfully')), 
      );
      _titleController.clear();
      _descriptionController.clear();
      _hourlyRateController.clear();
      _nicheController.clear();
      setState(() {
        _selectedSkills.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish gig: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nicheController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Mentor Gig'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Niche Prompt',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nicheController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Flutter app UI, social media growth',
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Enter your niche';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isGenerating ? null : _generateWithAI,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate Gig Draft with AI'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Gig Title', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Enter gig title'),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Please enter gig title'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Describe what you offer'),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Please enter description'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Hourly Rate (PKR)', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _hourlyRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g., 2500'),
                    validator: (value) {
                      final parsed = double.tryParse((value ?? '').trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Enter valid hourly rate';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Skills', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableSkills.map((skill) {
                      final selected = _selectedSkills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedSkills.add(skill);
                            } else {
                              _selectedSkills.remove(skill);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _publishGig,
                      child: Text(_isSaving ? 'Publishing...' : 'Publish Mentor Gig'),
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
