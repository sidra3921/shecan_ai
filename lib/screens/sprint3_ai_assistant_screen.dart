import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../constants/app_colors.dart';
import '../models/project_model.dart';
import '../services/ai_service.dart';
import '../services/supabase_database_service.dart';

class Sprint3AiAssistantScreen extends StatefulWidget {
  final String userId;
  final String userType;
  final int initialTabIndex;

  const Sprint3AiAssistantScreen({
    super.key,
    required this.userId,
    required this.userType,
    this.initialTabIndex = 0,
  });

  @override
  State<Sprint3AiAssistantScreen> createState() => _Sprint3AiAssistantScreenState();
}

class _Sprint3AiAssistantScreenState extends State<Sprint3AiAssistantScreen>
  {

  final _ai = GetIt.instance<AIService>();
  final _db = GetIt.instance<SupabaseDatabaseService>();

  bool _isGeneratingBrief = false;
  bool _isGeneratingProposal = false;
  bool _isCreatingDraftProject = false;

  final _goalController = TextEditingController();
  final _audienceController = TextEditingController();
  final _briefBudgetController = TextEditingController();
  final _briefTimelineController = TextEditingController();
  String _briefCategory = 'development';

  final _projectTitleController = TextEditingController();
  final _projectDescController = TextEditingController();
  final _strengthsController = TextEditingController();
  final _proposalBudgetController = TextEditingController();
  final _proposalTimelineController = TextEditingController();
  String _proposalTone = 'professional';

  Map<String, dynamic>? _briefDraft;
  Map<String, dynamic>? _proposalDraft;
  String _streamingBriefSummary = '';
  String _streamingProposalBody = '';

  bool get _isClient => widget.userType.trim().toLowerCase() == 'client';
  bool get _isMentor => widget.userType.trim().toLowerCase() == 'mentor';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _goalController.dispose();
    _audienceController.dispose();
    _briefBudgetController.dispose();
    _briefTimelineController.dispose();
    _projectTitleController.dispose();
    _projectDescController.dispose();
    _strengthsController.dispose();
    _proposalBudgetController.dispose();
    _proposalTimelineController.dispose();
    super.dispose();
  }

  Future<void> _generateBrief() async {
    final goal = _goalController.text.trim();
    if (goal.isEmpty) {
      _toast('Please enter your project goal first.');
      return;
    }

    setState(() {
      _isGeneratingBrief = true;
      _streamingBriefSummary = '';
    });

    try {
      final draft = await _ai.generateProjectBrief(
        goal: goal,
        targetAudience: _audienceController.text,
        budgetContext: _briefBudgetController.text,
        timelineContext: _briefTimelineController.text,
        category: _briefCategory,
      );

      final summary = draft['summary']?.toString() ?? '';
      await for (final partial in _ai.streamTextDraft(summary)) {
        if (!mounted) return;
        setState(() => _streamingBriefSummary = partial);
      }

      if (!mounted) return;
      setState(() => _briefDraft = draft);
    } catch (e) {
      _toast('Could not generate brief: $e');
    } finally {
      if (mounted) setState(() => _isGeneratingBrief = false);
    }
  }

  Future<void> _createProjectFromBrief() async {
    final draft = _briefDraft;
    if (draft == null || _isCreatingDraftProject) return;

    setState(() => _isCreatingDraftProject = true);
    try {
      final title = draft['title']?.toString() ?? 'AI Draft Project';
      final summary = draft['summary']?.toString() ?? _streamingBriefSummary;
      final category = draft['category']?.toString() ?? _briefCategory;
      final skills = (draft['recommendedSkills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[];
      final estimatedBudget = (draft['estimatedBudget'] as num?)?.toDouble() ?? 25000;

      final project = ProjectModel(
        id: '',
        title: title,
        description: summary,
        budget: estimatedBudget,
        deadline: DateTime.now().add(const Duration(days: 21)),
        status: 'pending',
        clientId: widget.userId,
        category: category,
        skills: skills,
      );

      final id = await _db.createProject(project);
      _toast('Draft project created successfully (ID: $id)');
    } catch (e) {
      _toast('Could not create project draft: $e');
    } finally {
      if (mounted) setState(() => _isCreatingDraftProject = false);
    }
  }

  Future<void> _generateProposal() async {
    final title = _projectTitleController.text.trim();
    final description = _projectDescController.text.trim();
    if (title.isEmpty || description.isEmpty) {
      _toast('Please enter project title and description first.');
      return;
    }

    setState(() {
      _isGeneratingProposal = true;
      _streamingProposalBody = '';
    });

    try {
      final draft = await _ai.generateProposalDraft(
        projectTitle: title,
        projectDescription: description,
        mentorStrengths: _strengthsController.text,
        proposedBudget: _proposalBudgetController.text,
        proposedTimeline: _proposalTimelineController.text,
        tone: _proposalTone,
      );

      final body = draft['proposalBody']?.toString() ?? '';
      await for (final partial in _ai.streamTextDraft(body)) {
        if (!mounted) return;
        setState(() => _streamingProposalBody = partial);
      }

      if (!mounted) return;
      setState(() => _proposalDraft = draft);
    } catch (e) {
      _toast('Could not generate proposal: $e');
    } finally {
      if (mounted) setState(() => _isGeneratingProposal = false);
    }
  }

  Future<void> _copyToClipboard(String content) async {
    if (content.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: content));
    _toast('Copied to clipboard');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isMentor ? 'AI Proposal Assistant' : 'AI Brief Assistant';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
      ),
      body: _isMentor ? _proposalTab() : _briefTab(),
    );
  }

  Widget _briefTab() {
    final draft = _briefDraft;
    final milestones = (draft?['milestones'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final success = (draft?['successCriteria'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final skills = (draft?['recommendedSkills'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard(
          title: 'Project Input',
          child: Column(
            children: [
              _input(_goalController, 'Project goal', maxLines: 2),
              _input(_audienceController, 'Target audience'),
              _input(_briefBudgetController, 'Budget context (optional)'),
              _input(_briefTimelineController, 'Timeline context (optional)'),
              DropdownButtonFormField<String>(
                initialValue: _briefCategory,
                items: const [
                  DropdownMenuItem(value: 'development', child: Text('Development')),
                  DropdownMenuItem(value: 'design', child: Text('Design')),
                  DropdownMenuItem(value: 'marketing', child: Text('Marketing')),
                  DropdownMenuItem(value: 'writing', child: Text('Writing')),
                  DropdownMenuItem(value: 'consulting', child: Text('Consulting')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _briefCategory = value);
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingBrief ? null : _generateBrief,
                  icon: _isGeneratingBrief
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGeneratingBrief ? 'Generating Brief...' : 'Generate AI Brief'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: draft == null ? 'Generated Brief' : (draft['title']?.toString() ?? 'Generated Brief'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _streamingBriefSummary.isNotEmpty
                    ? _streamingBriefSummary
                    : 'Generate a brief to get AI summary, milestones, and skill recommendations.',
              ),
              if (skills.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map((skill) => Chip(label: Text(skill), backgroundColor: AppColors.surface))
                      .toList(),
                ),
              ],
              if (milestones.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Milestones', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                ...milestones.map((m) => Text('• $m')),
              ],
              if (success.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Success Criteria', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                ...success.map((m) => Text('• $m')),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _streamingBriefSummary.trim().isEmpty
                        ? null
                        : () => _copyToClipboard(_streamingBriefSummary),
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy Brief'),
                  ),
                  if (_isClient)
                    ElevatedButton.icon(
                      onPressed: (_briefDraft == null || _isCreatingDraftProject)
                          ? null
                          : _createProjectFromBrief,
                      icon: _isCreatingDraftProject
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.post_add),
                      label: Text(
                        _isCreatingDraftProject ? 'Creating...' : 'Create Draft Project',
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _proposalTab() {
    final draft = _proposalDraft;
    final deliverables = (draft?['deliverables'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final clarifications = (draft?['clarifications'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard(
          title: 'Proposal Input',
          child: Column(
            children: [
              _input(_projectTitleController, 'Project title'),
              _input(_projectDescController, 'Project description', maxLines: 4),
              _input(_strengthsController, 'Your strengths and edge'),
              _input(_proposalBudgetController, 'Budget proposal'),
              _input(_proposalTimelineController, 'Delivery timeline'),
              DropdownButtonFormField<String>(
                initialValue: _proposalTone,
                items: const [
                  DropdownMenuItem(value: 'professional', child: Text('Professional')),
                  DropdownMenuItem(value: 'friendly', child: Text('Friendly')),
                  DropdownMenuItem(value: 'confident', child: Text('Confident')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _proposalTone = value);
                },
                decoration: const InputDecoration(
                  labelText: 'Tone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingProposal ? null : _generateProposal,
                  icon: _isGeneratingProposal
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bolt),
                  label: Text(_isGeneratingProposal ? 'Generating Proposal...' : 'Generate AI Proposal'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Generated Proposal',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _streamingProposalBody.isNotEmpty
                    ? _streamingProposalBody
                    : 'Generate a proposal to get an AI drafted outreach message.',
              ),
              if (deliverables.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Deliverables', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                ...deliverables.map((d) => Text('• $d')),
              ],
              if (clarifications.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Clarifications', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                ...clarifications.map((d) => Text('• $d')),
              ],
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _streamingProposalBody.trim().isEmpty
                    ? null
                    : () => _copyToClipboard(_streamingProposalBody),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy Proposal'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}