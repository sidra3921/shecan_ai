import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final _supabase = Supabase.instance.client;

  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const _defaultSkills = [
    'communication',
    'delivery planning',
    'client collaboration',
  ];

  Future<Map<String, dynamic>> generateResume({required String userId}) async {
    return {
      'userId': userId,
      'summary': 'AI resume generation is available after backend integration.',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> getChatHistory({
    required String userId,
  }) async {
    return [];
  }

  Future<String> generateAssistantReply({
    required String userId,
    required String userMessage,
    List<Map<String, String>> history = const [],
  }) async {
    final input = userMessage.trim();
    if (input.isEmpty) {
      return 'Please share your question and I will help right away.';
    }

    final realtimeContext = await _buildRealtimeContext(userId);
    final fallback = _buildFallbackReply(input, realtimeContext);
    final key = AppConfig.resolvedGeminiApiKey;

    if (key.isEmpty) {
      return '$fallback\n\nSet Gemini key with either --dart-define=GEMINI_API_KEY=... or AppConfig.geminiApiKeyFromCode.';
    }

    try {
      final prompt = _composeAssistantPrompt(
        userId: userId,
        userMessage: input,
        history: history,
        realtimeContext: realtimeContext,
      );

      final model = AppConfig.geminiModel.trim().isEmpty
          ? 'gemini-2.5-flash-lite'
          : AppConfig.geminiModel.trim();

      final uri = Uri.parse('$_geminiBaseUrl/$model:generateContent?key=$key');
      final response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 512},
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Gemini error ${response.statusCode}: ${response.body}');
        final reason = _extractGeminiError(response.body);
        return '$fallback\n\nI could not reach live AI right now (${response.statusCode}). $reason';
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final text = _extractGeminiText(decoded);
      if (text.trim().isEmpty) {
        return '$fallback\n\nLive AI returned an empty response. Please try again.';
      }
      return text.trim();
    } catch (e) {
      debugPrint('Gemini request failed: $e');
      return '$fallback\n\nI could not reach live AI right now. Please check internet and API key, then try again.';
    }
  }

  String _extractGeminiError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message']?.toString().trim() ?? '';
          if (message.isNotEmpty) return message;
        }
      }
    } catch (_) {}
    return 'Request was rejected by the API.';
  }

  String _extractGeminiText(Map<String, dynamic> decoded) {
    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) return '';

    final first = candidates.first;
    if (first is! Map<String, dynamic>) return '';

    final content = first['content'];
    if (content is! Map<String, dynamic>) return '';

    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) return '';

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map<String, dynamic>) {
        final text = part['text']?.toString() ?? '';
        if (text.isNotEmpty) {
          if (buffer.isNotEmpty) buffer.writeln();
          buffer.write(text);
        }
      }
    }

    return buffer.toString();
  }

  Future<Map<String, dynamic>> _buildRealtimeContext(String userId) async {
    final ctx = <String, dynamic>{
      'userId': userId,
      'nowUtc': DateTime.now().toUtc().toIso8601String(),
      'openProjects': 0,
      'myConversations': 0,
      'unreadNotifications': 0,
      'publishedCourses': 0,
      'mentorGigs': 0,
      'userType': 'unknown',
      'displayName': 'there',
    };

    try {
      final user = await _supabase
          .from('users')
          .select('display_name,user_type')
          .eq('id', userId)
          .maybeSingle();
      if (user != null) {
        final displayName = (user['display_name'] ?? '').toString().trim();
        if (displayName.isNotEmpty) ctx['displayName'] = displayName;
        ctx['userType'] = (user['user_type'] ?? 'unknown').toString();
      }
    } catch (_) {}

    try {
      final rows = await _supabase
          .from('projects')
          .select('id,status,client_id,freelancer_id')
          .or('client_id.eq.$userId,freelancer_id.eq.$userId');

      final list = (rows as List).cast<Map<String, dynamic>>();
      ctx['openProjects'] = list
          .where(
            (r) => (r['status'] ?? '').toString().toLowerCase() != 'completed',
          )
          .length;
    } catch (_) {}

    try {
      final rows = await _supabase
          .from('conversations')
          .select('id,participant_ids')
          .limit(500);
      final list = (rows as List).cast<Map<String, dynamic>>();
      ctx['myConversations'] = list.where((row) {
        final participants = (row['participant_ids'] as List?) ?? const [];
        return participants.contains(userId);
      }).length;
    } catch (_) {}

    try {
      final rows = await _supabase
          .from('notifications')
          .select('id,is_read,user_id')
          .eq('user_id', userId)
          .eq('is_read', false);
      ctx['unreadNotifications'] = (rows as List).length;
    } catch (_) {}

    try {
      final rows = await _supabase
          .from('courses')
          .select('id,is_published,mentor_id')
          .eq('mentor_id', userId)
          .eq('is_published', true);
      ctx['publishedCourses'] = (rows as List).length;
    } catch (_) {}

    try {
      final rows = await _supabase
          .from('mentor_gigs')
          .select('id,mentor_id')
          .eq('mentor_id', userId);
      ctx['mentorGigs'] = (rows as List).length;
    } catch (_) {}

    return ctx;
  }

  String _composeAssistantPrompt({
    required String userId,
    required String userMessage,
    required List<Map<String, String>> history,
    required Map<String, dynamic> realtimeContext,
  }) {
    final safeHistory = history
        .where((item) => (item['text'] ?? '').trim().isNotEmpty)
        .take(8)
        .map((item) {
          final role = (item['role'] ?? 'user').trim();
          final text = (item['text'] ?? '').trim();
          return '$role: $text';
        })
        .join('\n');

    return '''${AssistantConfig.systemPrompt}

You must answer with practical guidance for the SheCan platform.
Keep answers concise, clear, and supportive.
If user asks about platform status, use this realtime snapshot:
${jsonEncode(realtimeContext)}

Conversation context (most recent first):
$safeHistory

Current user id: $userId
Current user message: $userMessage

Return plain text only.''';
  }

  String _buildFallbackReply(String userMessage, Map<String, dynamic> context) {
    final text = userMessage.toLowerCase();
    final displayName = (context['displayName'] ?? 'there').toString();
    final openProjects = context['openProjects'] as int? ?? 0;
    final unreadNotifications = context['unreadNotifications'] as int? ?? 0;
    final conversations = context['myConversations'] as int? ?? 0;

    if (text.contains('earning') ||
        text.contains('wallet') ||
        text.contains('payment')) {
      return 'Hi $displayName. ${AssistantConfig.faqs['payment']} You currently have '
          '$unreadNotifications unread notifications, so check Notifications for payout updates.';
    }

    if (text.contains('profile')) {
      return 'Hi $displayName. ${AssistantConfig.faqs['profile']} '
          'You currently have $openProjects active projects, so keep your profile skills aligned with those project needs.';
    }

    return 'Hi $displayName. I can help with projects, payments, profile, and mentoring workflows. '
        'Right now you have $openProjects active projects, $conversations conversations, and '
        '$unreadNotifications unread notifications. Ask me what you want to improve next.';
  }

  Future<Map<String, dynamic>> generateGigDraft({
    required String prompt,
    String? preferredCategory,
    String? preferredExperienceLevel,
  }) async {
    final cleanedPrompt = prompt.trim();
    final normalized = cleanedPrompt.toLowerCase();

    final category = preferredCategory?.trim().isNotEmpty == true
        ? preferredCategory!.trim().toLowerCase()
        : _inferCategory(normalized);

    final experienceLevel = preferredExperienceLevel?.trim().isNotEmpty == true
        ? preferredExperienceLevel!.trim().toLowerCase()
        : 'intermediate';

    final title = _buildTitle(cleanedPrompt, category);
    final skills = _inferSkills(normalized);
    final description = _buildDescription(
      title: title,
      prompt: cleanedPrompt,
      category: category,
      experienceLevel: experienceLevel,
      skills: skills,
    );

    final hourlyRate = _suggestHourlyRate(category, experienceLevel);

    return {
      'title': title,
      'description': description,
      'category': category,
      'experienceLevel': experienceLevel,
      'skills': skills,
      'hourlyRate': hourlyRate,
      'packages': generateGigPackages(
        prompt: cleanedPrompt,
        category: category,
        hourlyRate: hourlyRate,
      ),
    };
  }

  Future<Map<String, dynamic>> generateProjectBrief({
    required String goal,
    required String targetAudience,
    required String budgetContext,
    required String timelineContext,
    required String category,
  }) async {
    final cleanGoal = goal.trim();
    final normalized = cleanGoal.toLowerCase();
    final inferredSkills = _inferSkills(normalized);
    final normalizedCategory = category.trim().isEmpty
        ? _inferCategory(normalized)
        : category.trim().toLowerCase();

    final estimatedBudget = _estimateBudgetFromText(
      budgetText: budgetContext,
      fallbackCategory: normalizedCategory,
    );

    final timeline = timelineContext.trim().isEmpty
        ? '2-4 weeks'
        : timelineContext.trim();
    final audience = targetAudience.trim().isEmpty
        ? 'your target users'
        : targetAudience.trim();

    final title = _buildProjectBriefTitle(cleanGoal, normalizedCategory);
    final summary =
        'This brief defines the scope for $title targeted at $audience. '
        'Primary objective: $cleanGoal. The delivery window is $timeline '
        'with an estimated budget of Rs ${estimatedBudget.toStringAsFixed(0)}.';

    final milestones = <String>[
      'Discovery and requirement alignment for $audience',
      'Design and implementation of core $normalizedCategory deliverables',
      'Testing, QA review, and stakeholder walkthrough',
      'Final handover with deployment or launch checklist',
    ];

    final successCriteria = <String>[
      'Measurable outcome aligned with business goal: $cleanGoal',
      'Usable and validated delivery for core user flow',
      'Documentation and ownership transfer completed',
    ];

    final risks = <String>[
      'Scope creep from unplanned feature additions',
      'Delay due to late feedback cycles',
      'Integration constraints with existing systems',
    ];

    return {
      'title': title,
      'summary': summary,
      'category': normalizedCategory,
      'recommendedSkills': inferredSkills,
      'estimatedBudget': estimatedBudget,
      'timeline': timeline,
      'milestones': milestones,
      'successCriteria': successCriteria,
      'risks': risks,
    };
  }

  Future<Map<String, dynamic>> generateProposalDraft({
    required String projectTitle,
    required String projectDescription,
    required String mentorStrengths,
    required String proposedBudget,
    required String proposedTimeline,
    required String tone,
  }) async {
    final cleanTitle = projectTitle.trim().isEmpty
        ? 'your project'
        : projectTitle.trim();
    final cleanDescription = projectDescription.trim();
    final cleanStrengths = mentorStrengths.trim().isEmpty
        ? 'reliable communication, practical delivery planning, and quality implementation'
        : mentorStrengths.trim();
    final cleanBudget = proposedBudget.trim().isEmpty
        ? 'as per agreed scope'
        : proposedBudget.trim();
    final cleanTimeline = proposedTimeline.trim().isEmpty
        ? 'based on final requirements'
        : proposedTimeline.trim();
    final cleanTone = tone.trim().toLowerCase().isEmpty
        ? 'professional'
        : tone.trim().toLowerCase();

    final opening = cleanTone == 'friendly'
        ? 'Thank you for sharing $cleanTitle. I am excited to support this project and can start quickly.'
        : 'Thank you for the opportunity to propose on $cleanTitle. I can deliver this with a structured and transparent workflow.';

    final approach =
        'I will begin with a short alignment session, then convert the requirements into delivery milestones. '
        'My strengths ($cleanStrengths) will help ensure predictable delivery and clear updates throughout execution.';

    final deliverables = <String>[
      'Detailed execution plan with milestones and checkpoints',
      'Working delivery aligned with the agreed scope',
      'Revision cycle and final handover documentation',
    ];

    final clarifications = <String>[
      'Please confirm priority features for phase 1.',
      'Do you have existing brand/design guidelines?',
      'Who is the final approver for milestone sign-off?',
    ];

    final proposalBody =
        '$opening\n\n'
        'Project understanding:\n$cleanDescription\n\n'
        'Execution approach:\n$approach\n\n'
        'Budget: $cleanBudget\n'
        'Timeline: $cleanTimeline\n\n'
        'I look forward to collaborating and delivering high-quality results.';

    return {
      'opening': opening,
      'approach': approach,
      'deliverables': deliverables,
      'clarifications': clarifications,
      'budgetText': cleanBudget,
      'timelineText': cleanTimeline,
      'proposalBody': proposalBody,
    };
  }

  Stream<String> streamTextDraft(String fullText) async* {
    final words = fullText.split(RegExp(r'\s+'));
    if (words.isEmpty) {
      yield '';
      return;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < words.length; i++) {
      if (i > 0) buffer.write(' ');
      buffer.write(words[i]);
      yield buffer.toString();
      await Future<void>.delayed(const Duration(milliseconds: 22));
    }
  }

  List<Map<String, dynamic>> generateGigPackages({
    required String prompt,
    required String category,
    required double hourlyRate,
  }) {
    final scope = prompt.trim().isEmpty
        ? 'your project requirements'
        : prompt.trim();

    final basePrice = hourlyRate <= 0 ? 2500 : hourlyRate;

    return [
      {
        'name': 'Basic',
        'price': (basePrice * 0.7).roundToDouble(),
        'deliveryDays': 3,
        'description':
            'Quick start package for $scope with clear requirements and one focused $category deliverable.',
      },
      {
        'name': 'Standard',
        'price': basePrice.roundToDouble(),
        'deliveryDays': 5,
        'description':
            'Balanced package covering planning, execution, and revision cycle for a complete $category milestone.',
      },
      {
        'name': 'Premium',
        'price': (basePrice * 1.6).roundToDouble(),
        'deliveryDays': 7,
        'description':
            'End-to-end package with priority collaboration, expanded scope, and post-delivery optimization support.',
      },
    ];
  }

  Stream<String> streamGigDescription(String fullDescription) async* {
    final words = fullDescription.split(RegExp(r'\s+'));
    if (words.isEmpty) {
      yield '';
      return;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < words.length; i++) {
      if (i > 0) buffer.write(' ');
      buffer.write(words[i]);
      yield buffer.toString();
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }
  }

  String _inferCategory(String normalizedPrompt) {
    if (normalizedPrompt.contains('flutter') ||
        normalizedPrompt.contains('app') ||
        normalizedPrompt.contains('website') ||
        normalizedPrompt.contains('supabase') ||
        normalizedPrompt.contains('firebase')) {
      return 'development';
    }
    if (normalizedPrompt.contains('design') ||
        normalizedPrompt.contains('ui') ||
        normalizedPrompt.contains('ux') ||
        normalizedPrompt.contains('branding')) {
      return 'design';
    }
    if (normalizedPrompt.contains('content') ||
        normalizedPrompt.contains('copy') ||
        normalizedPrompt.contains('writing')) {
      return 'writing';
    }
    if (normalizedPrompt.contains('marketing') ||
        normalizedPrompt.contains('social') ||
        normalizedPrompt.contains('ads')) {
      return 'marketing';
    }
    return 'consulting';
  }

  List<String> _inferSkills(String normalizedPrompt) {
    final skills = <String>[];
    final skillMap = <String, String>{
      'flutter': 'flutter',
      'supabase': 'supabase',
      'firebase': 'firebase',
      'ui': 'ui design',
      'ux': 'ux research',
      'branding': 'branding',
      'content': 'content strategy',
      'copy': 'copywriting',
      'social': 'social media',
      'marketing': 'digital marketing',
      'web': 'web development',
      'app': 'mobile development',
    };

    for (final entry in skillMap.entries) {
      if (normalizedPrompt.contains(entry.key)) {
        skills.add(entry.value);
      }
    }

    if (skills.isEmpty) {
      skills.addAll(_defaultSkills);
    }

    return skills.toSet().toList();
  }

  String _buildTitle(String prompt, String category) {
    if (prompt.isNotEmpty) {
      final cleaned = prompt
          .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
          .trim()
          .split(RegExp(r'\s+'))
          .take(8)
          .join(' ');
      if (cleaned.isNotEmpty) {
        return 'I will $cleaned';
      }
    }

    switch (category) {
      case 'development':
        return 'I will build and optimize your mobile product';
      case 'design':
        return 'I will design modern and conversion focused UI';
      case 'marketing':
        return 'I will create your growth and campaign strategy';
      case 'writing':
        return 'I will write high converting content and copy';
      default:
        return 'I will help you deliver your next milestone fast';
    }
  }

  String _buildDescription({
    required String title,
    required String prompt,
    required String category,
    required String experienceLevel,
    required List<String> skills,
  }) {
    final scopeLine = prompt.isEmpty
        ? 'I provide end-to-end delivery with clear milestones and fast response times.'
        : 'Based on your goals ($prompt), I provide a practical delivery plan with transparent communication.';

    return '$title. '
        'I specialize in $category projects at $experienceLevel level. '
        '$scopeLine '
        'What you get: clear scope, regular updates, quality assurance, and post-delivery support. '
        'Core skills: ${skills.join(', ')}.';
  }

  String _buildProjectBriefTitle(String goal, String category) {
    final cleaned = goal
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .take(8)
        .join(' ');
    if (cleaned.isNotEmpty) {
      return cleaned[0].toUpperCase() + cleaned.substring(1);
    }

    switch (category) {
      case 'development':
        return 'Product Build and Launch Brief';
      case 'design':
        return 'Design System and Experience Brief';
      case 'marketing':
        return 'Campaign Strategy Brief';
      case 'writing':
        return 'Content Execution Brief';
      default:
        return 'Project Delivery Brief';
    }
  }

  double _estimateBudgetFromText({
    required String budgetText,
    required String fallbackCategory,
  }) {
    final matches = RegExp(r'(\d{3,7})').allMatches(budgetText);
    if (matches.isNotEmpty) {
      final values = matches
          .map((m) => double.tryParse(m.group(1) ?? ''))
          .whereType<double>()
          .toList();
      if (values.isNotEmpty) {
        return values.reduce((a, b) => a + b) / values.length;
      }
    }

    final baseline = <String, double>{
      'development': 45000,
      'design': 28000,
      'marketing': 24000,
      'writing': 18000,
      'consulting': 22000,
    };
    return baseline[fallbackCategory] ?? 25000;
  }

  double _suggestHourlyRate(String category, String experienceLevel) {
    final baseByCategory = <String, double>{
      'development': 4500,
      'design': 3500,
      'marketing': 3000,
      'writing': 2500,
      'consulting': 3200,
    };

    final multiplierByLevel = <String, double>{
      'beginner': 0.8,
      'intermediate': 1.0,
      'expert': 1.35,
    };

    final base = baseByCategory[category] ?? 3000;
    final mult = multiplierByLevel[experienceLevel] ?? 1.0;
    return (base * mult).roundToDouble();
  }
}
