import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import 'content_moderation_service.dart';

class AiModerationDecision {
  final bool blocked;
  final String category;
  final String reason;

  const AiModerationDecision({
    required this.blocked,
    this.category = '',
    this.reason = '',
  });
}

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

  static const _gigCategories = ContentModerationService.safeGigCategories;

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
    try {
      await _ensureModerationOk(input);
    } catch (e) {
      debugPrint('Moderation blocked assistant input: $e');
      return 'This content violates platform safety policies.';
    }

    final realtimeContext = await _buildRealtimeContext(userId);
    final fallback = _buildFallbackReply(input, realtimeContext);
    final key = AppConfig.resolvedGeminiApiKey;

    if (key.isEmpty) {
      return '$fallback\n\nSet GEMINI_API_KEY with --dart-define before building the app.';
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
      try {
        await _ensureModerationOk(text);
      } catch (e) {
        debugPrint('Moderation blocked assistant output: $e');
        return 'This content violates platform safety policies.';
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

  Future<dynamic> _generateJsonWithGemini({
    required String prompt,
    int maxOutputTokens = 700,
    double temperature = 0.3,
  }) async {
    final key = AppConfig.resolvedGeminiApiKey;
    if (key.isEmpty) {
      throw Exception('Gemini API key not configured.');
    }

    final model = AppConfig.geminiModel.trim().isNotEmpty
        ? AppConfig.geminiModel.trim()
        : 'gemini-2.5-flash-lite';

    try {
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
              'generationConfig': {
                'temperature': temperature,
                'maxOutputTokens': maxOutputTokens,
              },
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'Gemini JSON error ${response.statusCode}: ${response.body}',
        );
        throw Exception('Gemini request failed (${response.statusCode}).');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final text = _extractGeminiText(decoded);
      if (text.trim().isEmpty) {
        throw Exception('Gemini returned empty response.');
      }

      final cleanedText = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final jsonStart = cleanedText.indexOf('{');
      final jsonEnd = cleanedText.lastIndexOf('}');
      final jsonText = jsonStart >= 0 && jsonEnd >= jsonStart
          ? cleanedText.substring(jsonStart, jsonEnd + 1)
          : cleanedText;

      final parsed = jsonDecode(jsonText);
      if (parsed is Map<String, dynamic> || parsed is List) return parsed;
      throw Exception('Gemini response is not JSON object/array.');
    } catch (e) {
      debugPrint('Gemini JSON parsing failed: $e');
      rethrow;
    }
  }

  Future<AiModerationDecision> moderateGigContent({
    required String text,
  }) async {
    final cleaned = text.trim();

    if (cleaned.isEmpty) {
      return const AiModerationDecision(blocked: false);
    }

    if (!AppConfig.enableRealGemini) {
      debugPrint('Gemini key not configured; using local moderation only.');
      return const AiModerationDecision(blocked: false);
    }

    final localMatch = ContentModerationService().findMatchInText(cleaned);
    if (localMatch != null) {
      return AiModerationDecision(
        blocked: true,
        category: localMatch.category,
        reason: 'This content violates platform safety policies.',
      );
    }

    final prompt =
        '''You are an enterprise-grade AI moderation system for a freelance marketplace.

Your task:
Analyze the USER CONTENT and determine if it contains illegal, unsafe, harmful, restricted, abusive, fraudulent, explicit, or policy-violating material.

IMPORTANT RULES:
- Be accurate and safety-focused.
- Do not block legitimate freelance services.
- Only block clear policy violations.
- Detect disguised/bypassed words.
- Detect intent even if wording is indirect.
- Detect obfuscated text like:
  - h@ck
  - dr*gs
  - weap0n
  - p0rn
  - s3x
- Ignore harmless normal freelance work.
- Only block content when there is CLEAR evidence of policy violation.
- Do NOT block normal freelance services.
- Safe categories: ${ContentModerationService.safeGigCategories.join(', ')}.
- Safe marketplace examples: ${ContentModerationService.safeGigKeywords.join(', ')}.

BLOCK these categories:
1. Drugs or narcotics
2. Weapons or explosives
3. Hacking or cybercrime
4. Fraud or scams
5. Fake documents
6. Adult or sexual services
7. Hate speech or extremism
8. Violence or threats
9. Child exploitation
10. Illegal medical claims
11. Academic cheating
12. Money laundering
13. Phishing
14. Malware
15. Terrorism
16. Piracy or copyright abuse
17. Fake engagement services
18. Identity theft
19. Illegal financial activities

Return ONLY valid JSON.

Allowed JSON format:
{
  "blocked": true,
  "category": "cybercrime",
  "reason": "Detected hacking-related service"
}

OR

{
  "blocked": false,
  "category": "",
  "reason": ""
}

USER CONTENT:
$cleaned
''';

    try {
      final response = await _generateJsonWithGemini(
        prompt: prompt,
        maxOutputTokens: 150,
        temperature: 0.0,
      );

      if (response is Map<String, dynamic>) {
        return AiModerationDecision(
          blocked: response['blocked'] == true,
          category: response['category']?.toString() ?? '',
          reason: response['reason']?.toString() ?? '',
        );
      }

      return const AiModerationDecision(
        blocked: true,
        category: 'unknown',
        reason: 'Invalid moderation response.',
      );
    } catch (e) {
      debugPrint('Moderation error: $e');

      final fallbackMatch = ContentModerationService().findMatchInText(cleaned);
      if (fallbackMatch != null) {
        return AiModerationDecision(
          blocked: true,
          category: fallbackMatch.category,
          reason: 'This content violates platform safety policies.',
        );
      }

      return const AiModerationDecision(
        blocked: false,
        category: '',
        reason: 'Live moderation unavailable; local moderation passed.',
      );
    }
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
    await _ensureModerationOk(cleanedPrompt);
    final promptText = _buildGigDraftPrompt(
      prompt: cleanedPrompt,
      preferredCategory: preferredCategory,
      preferredExperienceLevel: preferredExperienceLevel,
    );

    final response = await _generateJsonWithGemini(
      prompt: promptText,
      maxOutputTokens: 750,
      temperature: 0.4,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Gemini returned invalid gig draft.');
    }
    final fallback = _generateGigDraftLocal(
      prompt: cleanedPrompt,
      preferredCategory: preferredCategory,
      preferredExperienceLevel: preferredExperienceLevel,
    );
    final merged = _mergeGigDraft(response, fallback);
    await _ensureModerationOk(jsonEncode(merged));
    if (!_isGigDraftAligned(merged, cleanedPrompt) ||
        ContentModerationService().findMatchInPayload(merged) != null) {
      return fallback;
    }
    return merged;
  }

  Map<String, dynamic> _generateGigDraftLocal({
    required String prompt,
    String? preferredCategory,
    String? preferredExperienceLevel,
  }) {
    final cleanedPrompt = prompt.trim();
    final normalized = cleanedPrompt.toLowerCase();

    final requestedCategory = preferredCategory?.trim().toLowerCase() ?? '';
    final inferredCategory = _inferCategory(normalized);
    final category =
        requestedCategory.isNotEmpty && requestedCategory != 'development'
        ? requestedCategory
        : inferredCategory;

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

  String _buildGigDraftPrompt({
    required String prompt,
    String? preferredCategory,
    String? preferredExperienceLevel,
  }) {
    final category = preferredCategory?.trim().isEmpty == true
        ? ''
        : (preferredCategory ?? '').trim();
    final experience = preferredExperienceLevel?.trim().isEmpty == true
        ? ''
        : (preferredExperienceLevel ?? '').trim();

    return '''You are a gig draft generator for a freelance marketplace.
Return JSON only with keys:
title (string), description (string), category (string), experienceLevel (string),
skills (array of strings), hourlyRate (number), packages (array of objects with
name, price, deliveryDays, description).

  IMPORTANT:
  Never generate illegal, harmful, or policy-violating services.
  Reject requests involving hacking, fraud, adult content, fake documents, violence,
  extremism, or prohibited marketplace content.
  Allowed service keywords include: ${ContentModerationService.safeGigKeywords.join(', ')}.

Constraints:
- Keep text concise and professional.
- category must be one of: ${_gigCategories.join(', ')}.
- experienceLevel must be one of: beginner, intermediate, expert.
- Provide 3 packages: Basic, Standard, Premium.
- Use the user prompt as the only service topic. Do not introduce unrelated domains.
- Make title, description, skills, hourlyRate, and every package explicitly about the user prompt.
- If the prompt is "stitching", "tailor", "tailoring", "sewing", "alterations", or similar, create a tailoring gig with tailoring category, garment-related skills, and clothing service packages.
- Never reuse examples, stale titles, ecommerce, alcohol, or unrelated platform ideas.
- If the prompt is short, infer a complete professional service around that exact topic.

User prompt: ${prompt.trim()}
Preferred category: $category
Preferred experience: $experience
''';
  }

  Map<String, dynamic> _mergeGigDraft(
    Map<String, dynamic> response,
    Map<String, dynamic> fallback,
  ) {
    final skills = _toStringList(response['skills']);
    final packages = _toPackageList(response['packages']);

    return {
      'title': _toString(response['title'], fallback['title']),
      'description': _toString(
        response['description'],
        fallback['description'],
      ),
      'category': _toString(response['category'], fallback['category']),
      'experienceLevel': _toString(
        response['experienceLevel'],
        fallback['experienceLevel'],
      ),
      'skills': skills.isNotEmpty ? skills : (fallback['skills'] as List),
      'hourlyRate': _toDouble(response['hourlyRate'], fallback['hourlyRate']),
      'packages': packages.isNotEmpty
          ? packages
          : (fallback['packages'] as List).cast<Map<String, dynamic>>(),
    };
  }

  Future<Map<String, dynamic>> generateProjectBrief({
    required String goal,
    required String targetAudience,
    required String budgetContext,
    required String timelineContext,
    required String category,
  }) async {
    await _ensureModerationOk(
      [
        goal,
        targetAudience,
        budgetContext,
        timelineContext,
        category,
      ].where((item) => item.trim().isNotEmpty).join(' '),
    );
    final promptText = _buildProjectBriefPrompt(
      goal: goal,
      targetAudience: targetAudience,
      budgetContext: budgetContext,
      timelineContext: timelineContext,
      category: category,
    );

    final response = await _generateJsonWithGemini(
      prompt: promptText,
      maxOutputTokens: 700,
      temperature: 0.35,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Gemini returned invalid project brief.');
    }
    final merged = _mergeProjectBrief(
      response,
      _generateProjectBriefLocal(
        goal: goal,
        targetAudience: targetAudience,
        budgetContext: budgetContext,
        timelineContext: timelineContext,
        category: category,
      ),
    );
    await _ensureModerationOk(jsonEncode(merged));
    return merged;
  }

  Future<Map<String, dynamic>> generateProposalDraft({
    required String projectTitle,
    required String projectDescription,
    required String mentorStrengths,
    required String proposedBudget,
    required String proposedTimeline,
    required String tone,
  }) async {
    await _ensureModerationOk(
      [
        projectTitle,
        projectDescription,
        mentorStrengths,
        proposedBudget,
        proposedTimeline,
        tone,
      ].where((item) => item.trim().isNotEmpty).join(' '),
    );
    final promptText = _buildProposalDraftPrompt(
      projectTitle: projectTitle,
      projectDescription: projectDescription,
      mentorStrengths: mentorStrengths,
      proposedBudget: proposedBudget,
      proposedTimeline: proposedTimeline,
      tone: tone,
    );

    final response = await _generateJsonWithGemini(
      prompt: promptText,
      maxOutputTokens: 700,
      temperature: 0.4,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Gemini returned invalid proposal draft.');
    }
    final merged = _mergeProposalDraft(
      response,
      _generateProposalDraftLocal(
        projectTitle: projectTitle,
        projectDescription: projectDescription,
        mentorStrengths: mentorStrengths,
        proposedBudget: proposedBudget,
        proposedTimeline: proposedTimeline,
        tone: tone,
      ),
    );
    await _ensureModerationOk(jsonEncode(merged));
    return merged;
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

  Future<List<Map<String, dynamic>>> generateGigPackagesWithAI({
    required String prompt,
    required String category,
    required double hourlyRate,
  }) async {
    await _ensureModerationOk(
      [
        prompt,
        category,
        hourlyRate.toStringAsFixed(0),
      ].where((item) => item.trim().isNotEmpty).join(' '),
    );
    final promptText =
        '''You are a gig package generator for a freelance marketplace.
Return JSON only as an array of 3 objects with keys: name, price, deliveryDays, description.
Use package names exactly: Basic, Standard, Premium.
  Packages must be explicitly about the user prompt. Do not add unrelated services.

IMPORTANT:
Never generate illegal, harmful, or policy-violating services.
Reject requests involving hacking, fraud, adult content, fake documents, violence,
extremism, or prohibited marketplace content.
Category: ${category.trim()}
Hourly rate: ${hourlyRate.toStringAsFixed(0)}
Prompt: ${prompt.trim()}
''';

    final response = await _generateJsonWithGemini(
      prompt: promptText,
      maxOutputTokens: 420,
      temperature: 0.4,
    );

    final packages = _toPackageList(
      response is Map<String, dynamic> ? response['packages'] : response,
    );
    if (packages.isEmpty) {
      throw Exception('Gemini returned invalid package data.');
    }
    await _ensureModerationOk(jsonEncode(packages));
    return packages;
  }

  List<Map<String, dynamic>> generateGigPackages({
    required String prompt,
    required String category,
    required double hourlyRate,
  }) {
    final normalized = prompt.trim().toLowerCase();
    final scope = prompt.trim().isEmpty
        ? 'your project requirements'
        : prompt.trim();

    final basePrice = hourlyRate <= 0 ? 2500 : hourlyRate;

    if (_isTailoringPrompt(normalized) || category == 'tailoring') {
      return [
        {
          'name': 'Basic',
          'price': (basePrice * 0.7).roundToDouble(),
          'deliveryDays': 2,
          'description':
              'Simple stitching or alteration for one garment, including measurement review, fitting guidance, and neat finishing.',
        },
        {
          'name': 'Standard',
          'price': basePrice.roundToDouble(),
          'deliveryDays': 4,
          'description':
              'Custom tailoring for one complete outfit with cutting, stitching, fitting adjustments, and quality finishing.',
        },
        {
          'name': 'Premium',
          'price': (basePrice * 1.6).roundToDouble(),
          'deliveryDays': 7,
          'description':
              'Detailed tailoring package for a premium outfit or multiple alterations with consultation, fitting revisions, and final pressing guidance.',
        },
      ];
    }

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

  Map<String, dynamic> _generateProjectBriefLocal({
    required String goal,
    required String targetAudience,
    required String budgetContext,
    required String timelineContext,
    required String category,
  }) {
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

  String _buildProjectBriefPrompt({
    required String goal,
    required String targetAudience,
    required String budgetContext,
    required String timelineContext,
    required String category,
  }) {
    return '''You are an AI project brief generator.
Return JSON only with keys:
title, summary, category, recommendedSkills (array), estimatedBudget (number),
timeline (string), milestones (array), successCriteria (array), risks (array).

IMPORTANT:
Never generate illegal, harmful, or policy-violating services.
Reject requests involving hacking, fraud, adult content, fake documents, violence,
extremism, or prohibited marketplace content.

Constraints:
- category must be one of: development, design, marketing, writing, consulting.
- Keep summary concise and professional.

Goal: ${goal.trim()}
Target audience: ${targetAudience.trim()}
Budget context: ${budgetContext.trim()}
Timeline: ${timelineContext.trim()}
Category: ${category.trim()}
''';
  }

  Map<String, dynamic> _mergeProjectBrief(
    Map<String, dynamic> response,
    Map<String, dynamic> fallback,
  ) {
    final skills = _toStringList(response['recommendedSkills']);
    final milestones = _toStringList(response['milestones']);
    final success = _toStringList(response['successCriteria']);
    final risks = _toStringList(response['risks']);

    return {
      'title': _toString(response['title'], fallback['title']),
      'summary': _toString(response['summary'], fallback['summary']),
      'category': _toString(response['category'], fallback['category']),
      'recommendedSkills': skills.isNotEmpty
          ? skills
          : (fallback['recommendedSkills'] as List),
      'estimatedBudget': _toDouble(
        response['estimatedBudget'],
        fallback['estimatedBudget'],
      ),
      'timeline': _toString(response['timeline'], fallback['timeline']),
      'milestones': milestones.isNotEmpty
          ? milestones
          : (fallback['milestones'] as List),
      'successCriteria': success.isNotEmpty
          ? success
          : (fallback['successCriteria'] as List),
      'risks': risks.isNotEmpty ? risks : (fallback['risks'] as List),
    };
  }

  Map<String, dynamic> _generateProposalDraftLocal({
    required String projectTitle,
    required String projectDescription,
    required String mentorStrengths,
    required String proposedBudget,
    required String proposedTimeline,
    required String tone,
  }) {
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

  String _buildProposalDraftPrompt({
    required String projectTitle,
    required String projectDescription,
    required String mentorStrengths,
    required String proposedBudget,
    required String proposedTimeline,
    required String tone,
  }) {
    return '''You are an AI proposal generator for a freelancer.
Return JSON only with keys:
opening, approach, deliverables (array), clarifications (array),
budgetText, timelineText, proposalBody.

IMPORTANT:
Never generate illegal, harmful, or policy-violating services.
Reject requests involving hacking, fraud, adult content, fake documents, violence,
extremism, or prohibited marketplace content.

Constraints:
- Tone must match: ${tone.trim().isEmpty ? 'professional' : tone.trim().toLowerCase()}.
- Keep the proposal concise and client-friendly.

Project title: ${projectTitle.trim()}
Project description: ${projectDescription.trim()}
Mentor strengths: ${mentorStrengths.trim()}
Budget: ${proposedBudget.trim()}
Timeline: ${proposedTimeline.trim()}
''';
  }

  Map<String, dynamic> _mergeProposalDraft(
    Map<String, dynamic> response,
    Map<String, dynamic> fallback,
  ) {
    final deliverables = _toStringList(response['deliverables']);
    final clarifications = _toStringList(response['clarifications']);

    return {
      'opening': _toString(response['opening'], fallback['opening']),
      'approach': _toString(response['approach'], fallback['approach']),
      'deliverables': deliverables.isNotEmpty
          ? deliverables
          : (fallback['deliverables'] as List),
      'clarifications': clarifications.isNotEmpty
          ? clarifications
          : (fallback['clarifications'] as List),
      'budgetText': _toString(response['budgetText'], fallback['budgetText']),
      'timelineText': _toString(
        response['timelineText'],
        fallback['timelineText'],
      ),
      'proposalBody': _toString(
        response['proposalBody'],
        fallback['proposalBody'],
      ),
    };
  }

  String _toString(dynamic value, dynamic fallback) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
    return fallback?.toString().trim() ?? '';
  }

  List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    return const [];
  }

  List<Map<String, dynamic>> _toPackageList(dynamic value) {
    if (value is! List) return const [];
    final packages = <Map<String, dynamic>>[];
    for (final item in value) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final name = map['name']?.toString() ?? '';
        if (name.trim().isEmpty) continue;
        packages.add({
          'name': name,
          'price': _toDouble(map['price'], 0),
          'deliveryDays': _toInt(map['deliveryDays'], 0),
          'description': map['description']?.toString() ?? '',
        });
      }
    }
    return packages;
  }

  double _toDouble(dynamic value, dynamic fallback) {
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    if (fallback is num) return fallback.toDouble();
    return double.tryParse(fallback?.toString() ?? '') ?? 0;
  }

  int _toInt(dynamic value, dynamic fallback) {
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    if (fallback is num) return fallback.toInt();
    return int.tryParse(fallback?.toString() ?? '') ?? 0;
  }

  Future<void> _ensureModerationOk(String text) async {
    final cleaned = text.trim();

    if (cleaned.isEmpty) return;

    ContentModerationService().validateText(cleaned);

    final result = await moderateGigContent(text: cleaned);
    if (result.blocked) {
      debugPrint('Moderation blocked content: ${result.reason}');
      throw Exception(
        result.reason.trim().isNotEmpty
            ? result.reason.trim()
            : 'This content violates platform safety policies.',
      );
    }
  }

  String _inferCategory(String normalizedPrompt) {
    if (_isTailoringPrompt(normalizedPrompt)) {
      return 'tailoring';
    }
    if (normalizedPrompt.contains('baking') ||
        normalizedPrompt.contains('cake') ||
        normalizedPrompt.contains('cupcake') ||
        normalizedPrompt.contains('dessert') ||
        normalizedPrompt.contains('bakery') ||
        normalizedPrompt.contains('cookie') ||
        normalizedPrompt.contains('catering') ||
        normalizedPrompt.contains('meal preparation') ||
        normalizedPrompt.contains('cooking')) {
      return 'baking';
    }
    if (normalizedPrompt.contains('makeup') ||
        normalizedPrompt.contains('mehndi') ||
        normalizedPrompt.contains('henna') ||
        normalizedPrompt.contains('hair styling') ||
        normalizedPrompt.contains('skin care') ||
        normalizedPrompt.contains('salon') ||
        normalizedPrompt.contains('beauty')) {
      return 'beauty';
    }
    if (normalizedPrompt.contains('tutor') ||
        normalizedPrompt.contains('teaching') ||
        normalizedPrompt.contains('classes') ||
        normalizedPrompt.contains('homework') ||
        normalizedPrompt.contains('spoken english') ||
        normalizedPrompt.contains('quran') ||
        normalizedPrompt.contains('education')) {
      return 'education';
    }
    if (normalizedPrompt.contains('craft') ||
        normalizedPrompt.contains('handmade') ||
        normalizedPrompt.contains('calligraphy') ||
        normalizedPrompt.contains('jewelry') ||
        normalizedPrompt.contains('resin art') ||
        normalizedPrompt.contains('home decor') ||
        normalizedPrompt.contains('sketching') ||
        normalizedPrompt.contains('painting')) {
      return 'crafts';
    }
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
    if (normalizedPrompt.contains('virtual assistant') ||
        normalizedPrompt.contains('data entry') ||
        normalizedPrompt.contains('customer support') ||
        normalizedPrompt.contains('appointment scheduling') ||
        normalizedPrompt.contains('business consultation') ||
        normalizedPrompt.contains('project management')) {
      return 'business';
    }
    return 'consulting';
  }

  List<String> _inferSkills(String normalizedPrompt) {
    if (_isTailoringPrompt(normalizedPrompt)) {
      return [
        'custom stitching',
        'tailoring',
        'garment alterations',
        'measurements',
        'fabric cutting',
        'hemming',
        'fitting adjustments',
      ];
    }

    final skills = <String>[];
    final skillMap = <String, String>{
      'baking': 'baking',
      'cake': 'custom cakes',
      'dessert': 'desserts',
      'catering': 'catering',
      'makeup': 'makeup',
      'mehndi': 'mehndi',
      'henna': 'henna design',
      'salon': 'salon services',
      'tutor': 'tutoring',
      'teaching': 'online teaching',
      'homework': 'homework support',
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
      'craft': 'handicrafts',
      'handmade': 'handmade gifts',
      'calligraphy': 'calligraphy',
      'data entry': 'data entry',
      'customer support': 'customer support',
      'virtual assistant': 'virtual assistant',
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
    final normalizedPrompt = prompt.toLowerCase();
    if (_isTailoringPrompt(normalizedPrompt) || category == 'tailoring') {
      return 'I will provide custom stitching and tailoring services';
    }

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
      case 'tailoring':
        return 'I will provide custom stitching and tailoring services';
      case 'baking':
        return 'I will bake custom cakes and desserts for your event';
      case 'beauty':
        return 'I will provide beauty and grooming services';
      case 'education':
        return 'I will provide online tutoring and learning support';
      case 'crafts':
        return 'I will create handmade crafts and custom gifts';
      case 'business':
        return 'I will support your business operations remotely';
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

    if (_isTailoringPrompt(prompt.toLowerCase()) || category == 'tailoring') {
      return '$title. '
          'I create, alter, and repair garments with careful measurements, neat stitching, and clean finishing. '
          'You can request custom outfits, size adjustments, hemming, zipper replacement, sleeve or waist fitting, and everyday clothing repairs. '
          'Each order includes requirement discussion, measurement guidance, fabric and style clarification, progress updates, and final quality checks. '
          'Core skills: ${skills.join(', ')}.';
    }

    if (category == 'baking') {
      return '$title. '
          'I prepare fresh baked items with clear order details, flavor preferences, portion planning, and reliable delivery coordination. '
          'You can request cakes, cupcakes, cookies, desserts, snacks, catering items, recipe writing, or cooking classes. '
          'Core skills: ${skills.join(', ')}.';
    }

    if (category == 'beauty') {
      return '$title. '
          'I provide client-friendly beauty support for makeup, mehndi, hair styling, nail art, self grooming, and consultation needs. '
          'Each order includes style discussion, preparation guidance, and clear service expectations. '
          'Core skills: ${skills.join(', ')}.';
    }

    if (category == 'education') {
      return '$title. '
          'I support learners with structured tutoring, online classes, homework support, spoken English, and subject-focused guidance. '
          'Lessons are planned around the student level, goals, and pace. '
          'Core skills: ${skills.join(', ')}.';
    }

    if (category == 'crafts') {
      return '$title. '
          'I create thoughtful handmade work such as artwork, calligraphy, jewelry, paper crafts, resin art, decor items, and custom gifts. '
          'Each order includes style discussion, material planning, and revision support where suitable. '
          'Core skills: ${skills.join(', ')}.';
    }

    if (category == 'business') {
      return '$title. '
          'I help with organized remote business support including data entry, customer support, research, scheduling, planning, and admin tasks. '
          'You get clear communication, reliable turnaround, and structured task tracking. '
          'Core skills: ${skills.join(', ')}.';
    }

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
      case 'tailoring':
        return 'Custom Tailoring Service Brief';
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
      'tailoring': 12000,
      'crafts': 14000,
      'beauty': 12000,
      'education': 15000,
      'business': 22000,
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
      'tailoring': 1800,
      'crafts': 1800,
      'beauty': 1800,
      'education': 2200,
      'business': 3200,
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

  bool _isTailoringPrompt(String normalizedPrompt) {
    return normalizedPrompt.contains('tailor') ||
        normalizedPrompt.contains('tailoring') ||
        normalizedPrompt.contains('stitch') ||
        normalizedPrompt.contains('stich') ||
        normalizedPrompt.contains('sewing') ||
        normalizedPrompt.contains('sew ') ||
        normalizedPrompt.contains('garment') ||
        normalizedPrompt.contains('alteration') ||
        normalizedPrompt.contains('hemming') ||
        normalizedPrompt.contains('cloth');
  }

  bool _isGigDraftAligned(Map<String, dynamic> draft, String prompt) {
    final promptTokens = prompt
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.length >= 4)
        .toSet();
    if (promptTokens.isEmpty) return true;

    final skills = draft['skills'] is List
        ? (draft['skills'] as List).map((item) => item.toString())
        : const Iterable<String>.empty();
    final packages = draft['packages'] is List
        ? (draft['packages'] as List).map((item) => item.toString())
        : const Iterable<String>.empty();
    final generated = [
      draft['title']?.toString() ?? '',
      draft['description']?.toString() ?? '',
      ...skills,
      ...packages,
    ].join(' ').toLowerCase();

    if (_isTailoringPrompt(prompt.toLowerCase())) {
      return _isTailoringPrompt(generated);
    }

    return promptTokens.any(generated.contains);
  }
}
