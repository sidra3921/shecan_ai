import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../../../constants/app_colors.dart';
import '../../../models/mentor_gig_model.dart';
import '../../../services/ai_service.dart';
import '../../../services/supabase_database_service.dart';
import '../../../services/supabase_storage_service.dart';

class AddServiceScreen extends StatefulWidget {
  final String mentorId;
  final MentorGigModel? initialGig;

  const AddServiceScreen({
    super.key,
    required this.mentorId,
    this.initialGig,
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _skillsController = TextEditingController();
  final _promptController = TextEditingController();
  final _basicPriceController = TextEditingController();
  final _basicDaysController = TextEditingController();
  final _basicDescController = TextEditingController();
  final _standardPriceController = TextEditingController();
  final _standardDaysController = TextEditingController();
  final _standardDescController = TextEditingController();
  final _premiumPriceController = TextEditingController();
  final _premiumDaysController = TextEditingController();
  final _premiumDescController = TextEditingController();

  String _category = 'development';
  String _experienceLevel = 'intermediate';
  bool _isGenerating = false;
  bool _isSaving = false;
  Uint8List? _selectedImageBytes;
  String _selectedImageExt = 'jpg';
  String _existingImageUrl = '';

  final _categories = const [
    'development',
    'design',
    'marketing',
    'writing',
    'consulting',
  ];

  final _experienceLevels = const ['beginner', 'intermediate', 'expert'];

  bool get _isEditing => widget.initialGig != null;

  @override
  void initState() {
    super.initState();
    final gig = widget.initialGig;
    if (gig != null) {
      _titleController.text = gig.title;
      _descriptionController.text = gig.description;
      _priceController.text = gig.hourlyRate.toStringAsFixed(0);
      _skillsController.text = gig.skills.join(', ');
      _category = gig.category ?? _category;
      _experienceLevel = gig.experienceLevel ?? _experienceLevel;
      _existingImageUrl = gig.imageUrl;
      _applyPackages(gig.packages);
    } else {
      _applyPackages(const []);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _skillsController.dispose();
    _promptController.dispose();
    _basicPriceController.dispose();
    _basicDaysController.dispose();
    _basicDescController.dispose();
    _standardPriceController.dispose();
    _standardDaysController.dispose();
    _standardDescController.dispose();
    _premiumPriceController.dispose();
    _premiumDaysController.dispose();
    _premiumDescController.dispose();
    super.dispose();
  }

  void _applyPackages(List<dynamic> raw) {
    final fallback = AIService().generateGigPackages(
      prompt: _promptController.text,
      category: _category,
      hourlyRate: double.tryParse(_priceController.text.trim()) ?? 2500,
    );

    final packages = raw.isEmpty
        ? fallback
        : raw
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

    Map<String, dynamic> byName(String name, int index) {
      final found = packages.where((p) =>
          p['name']?.toString().toLowerCase() == name.toLowerCase());
      if (found.isNotEmpty) return found.first;
      if (index < packages.length) return packages[index];
      return fallback[index];
    }

    final basic = byName('Basic', 0);
    final standard = byName('Standard', 1);
    final premium = byName('Premium', 2);

    _basicPriceController.text = (basic['price'] ?? '').toString();
    _basicDaysController.text = (basic['deliveryDays'] ?? '').toString();
    _basicDescController.text = (basic['description'] ?? '').toString();

    _standardPriceController.text = (standard['price'] ?? '').toString();
    _standardDaysController.text = (standard['deliveryDays'] ?? '').toString();
    _standardDescController.text = (standard['description'] ?? '').toString();

    _premiumPriceController.text = (premium['price'] ?? '').toString();
    _premiumDaysController.text = (premium['deliveryDays'] ?? '').toString();
    _premiumDescController.text = (premium['description'] ?? '').toString();
  }

  List<Map<String, dynamic>> _collectPackages() {
    return [
      {
        'name': 'Basic',
        'price': double.tryParse(_basicPriceController.text.trim()) ?? 0,
        'deliveryDays': int.tryParse(_basicDaysController.text.trim()) ?? 0,
        'description': _basicDescController.text.trim(),
      },
      {
        'name': 'Standard',
        'price': double.tryParse(_standardPriceController.text.trim()) ?? 0,
        'deliveryDays': int.tryParse(_standardDaysController.text.trim()) ?? 0,
        'description': _standardDescController.text.trim(),
      },
      {
        'name': 'Premium',
        'price': double.tryParse(_premiumPriceController.text.trim()) ?? 0,
        'deliveryDays': int.tryParse(_premiumDaysController.text.trim()) ?? 0,
        'description': _premiumDescController.text.trim(),
      },
    ];
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final split = picked.name.split('.');
      final ext = split.length > 1 ? split.last.toLowerCase() : 'jpg';

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageExt = ext;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e')),
      );
    }
  }

  List<String> _parseSkills(String raw) {
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> _generateWithAI() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a prompt first for AI generation.')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final ai = AIService();
      final draft = await ai.generateGigDraft(
        prompt: prompt,
        preferredCategory: _category,
        preferredExperienceLevel: _experienceLevel,
      );

      if (_titleController.text.trim().isEmpty) {
        _titleController.text = (draft['title'] ?? '').toString();
      }

      _category = (draft['category'] ?? _category).toString();
      _experienceLevel = (draft['experienceLevel'] ?? _experienceLevel).toString();
      _priceController.text = (draft['hourlyRate'] ?? 0).toString();
      _applyPackages((draft['packages'] as List?) ?? const []);

      final skills = (draft['skills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[];
      if (skills.isNotEmpty) {
        _skillsController.text = skills.join(', ');
      }

      final fullDescription = (draft['description'] ?? '').toString();
      await for (final partial in ai.streamGigDescription(fullDescription)) {
        if (!mounted) return;
        _descriptionController.text = partial;
        _descriptionController.selection = TextSelection.fromPosition(
          TextPosition(offset: _descriptionController.text.length),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('AI generation failed: $e')));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _saveGig() async {
    if (!_formKey.currentState!.validate()) return;

    final hourlyRate = double.tryParse(_priceController.text.trim()) ?? 0;
    final skills = _parseSkills(_skillsController.text);
    final packages = _collectPackages();

    setState(() => _isSaving = true);
    try {
      final db = GetIt.instance<SupabaseDatabaseService>();
      final storage = GetIt.instance<SupabaseStorageService>();
      String imageUrl = _existingImageUrl;
      String gigId;

      if (_isEditing) {
        gigId = widget.initialGig!.id;
        if (_selectedImageBytes != null) {
          imageUrl = await storage.uploadGigImageBytes(
            mentorId: widget.mentorId,
            gigId: gigId,
            bytes: _selectedImageBytes!,
            extension: _selectedImageExt,
          );
        }

        await db.updateMentorGig(widget.initialGig!.id, {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'skills': skills,
          'category': _category,
          'experience_level': _experienceLevel,
          'hourly_rate': hourlyRate,
          'packages': packages,
          'image_url': imageUrl,
          'is_active': widget.initialGig!.isActive,
        });
      } else {
        final gig = MentorGigModel(
          id: '',
          mentorId: widget.mentorId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          skills: skills,
          category: _category,
          experienceLevel: _experienceLevel,
          hourlyRate: hourlyRate,
          imageUrl: '',
          packages: packages,
        );
        gigId = await db.createMentorGig(gig);

        if (_selectedImageBytes != null) {
          imageUrl = await storage.uploadGigImageBytes(
            mentorId: widget.mentorId,
            gigId: gigId,
            bytes: _selectedImageBytes!,
            extension: _selectedImageExt,
          );
          await db.updateMentorGig(gigId, {'image_url': imageUrl});
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Service updated successfully' : 'Service created successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save service: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Service' : 'Add Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _promptController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText:
                      'Describe the gig you want. Example: Flutter app UI and Supabase backend setup',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateWithAI,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? 'Generating...' : 'Generate with AI'),
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Gig Cover Image',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surface),
                  ),
                  child: _selectedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _selectedImageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : (_existingImageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _existingImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined),
                                    SizedBox(height: 8),
                                    Text('Tap to upload cover image'),
                                  ],
                                ),
                              )),
                ),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _titleController,
                hint: 'Title',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              _field(
                controller: _descriptionController,
                hint: 'Description',
                maxLines: 5,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),
              _field(
                controller: _skillsController,
                hint: 'Skills (comma separated)',
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _category = v);
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _experienceLevel,
                      items: _experienceLevels
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _experienceLevel = v);
                      },
                      decoration: InputDecoration(
                        labelText: 'Experience',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                controller: _priceController,
                hint: 'Hourly Rate (Rs)',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = double.tryParse((v ?? '').trim());
                  if (value == null || value <= 0) {
                    return 'Enter a valid hourly rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _applyPackages(
                          AIService().generateGigPackages(
                            prompt: _promptController.text,
                            category: _category,
                            hourlyRate:
                                double.tryParse(_priceController.text.trim()) ?? 2500,
                          ),
                        );
                        setState(() {});
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate Packages'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _packageCard(
                name: 'Basic',
                priceController: _basicPriceController,
                daysController: _basicDaysController,
                descriptionController: _basicDescController,
              ),
              _packageCard(
                name: 'Standard',
                priceController: _standardPriceController,
                daysController: _standardDaysController,
                descriptionController: _standardDescController,
              ),
              _packageCard(
                name: 'Premium',
                priceController: _premiumPriceController,
                daysController: _premiumDaysController,
                descriptionController: _premiumDescController,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: _isSaving ? null : _saveGig,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Update Service' : 'Create Service',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _packageCard({
    required String name,
    required TextEditingController priceController,
    required TextEditingController daysController,
    required TextEditingController descriptionController,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _field(
                  controller: priceController,
                  hint: 'Price',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _field(
                  controller: daysController,
                  hint: 'Delivery days',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          _field(
            controller: descriptionController,
            hint: 'What is included in this package?',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
