class ContentPolicyViolation implements Exception {
  final ModerationMatch match;

  const ContentPolicyViolation(this.match);

  @override
  String toString() => ContentModerationService.violationMessage;
}

class ModerationMatch {
  final String keyword;
  final String category;
  final String severity;

  const ModerationMatch({
    required this.keyword,
    required this.category,
    required this.severity,
  });
}

class ContentModerationService {
  static final ContentModerationService _instance =
      ContentModerationService._internal();
  factory ContentModerationService() => _instance;
  ContentModerationService._internal();

  static const violationMessage =
      'This content violates platform safety policies.';
  static const gigViolationMessage = 'This gig contains prohibited content.';

  static const safeGigCategories = [
    'tailoring',
    'education',
    'design',
    'development',
    'beauty',
    'baking',
    'crafts',
    'marketing',
    'writing',
    'business',
  ];

  static const safeGigKeywords = [
    'stitching',
    'tailoring',
    'sewing',
    'custom stitching',
    'garment stitching',
    'hemming',
    'alterations',
    'dress stitching',
    'ladies tailoring',
    'kids clothes stitching',
    'abaya stitching',
    'kurti stitching',
    'blouse stitching',
    'fashion design',
    'fabric cutting',
    'measurement fitting',
    'clothing repair',
    'boutique work',
    'embroidery',
    'hand embroidery',
    'machine embroidery',
    'crochet',
    'knitting',
    'makeup',
    'bridal makeup',
    'party makeup',
    'mehndi',
    'henna design',
    'hair styling',
    'skin care consultation',
    'beauty consultation',
    'nail art',
    'eyebrow shaping',
    'beauty tutorials',
    'salon services',
    'self grooming',
    'baking',
    'cake baking',
    'cupcakes',
    'desserts',
    'home bakery',
    'cookies',
    'custom cakes',
    'birthday cakes',
    'food delivery',
    'meal preparation',
    'cooking classes',
    'recipe writing',
    'catering',
    'snacks preparation',
    'tutoring',
    'online tutoring',
    'math tutor',
    'science tutor',
    'english tutor',
    'urdu tutor',
    'islamic studies',
    'quran teaching',
    'assignment help',
    'spoken english',
    'kids learning',
    'homework support',
    'online classes',
    'teacher assistant',
    'education consultation',
    'content writing',
    'blog writing',
    'article writing',
    'copywriting',
    'proofreading',
    'editing',
    'script writing',
    'creative writing',
    'resume writing',
    'cv design',
    'translation',
    'urdu translation',
    'english translation',
    'caption writing',
    'product descriptions',
    'ghostwriting',
    'technical writing',
    'graphic design',
    'logo design',
    'poster design',
    'flyer design',
    'social media posts',
    'branding',
    'business card design',
    'ui design',
    'ux design',
    'thumbnail design',
    'banner design',
    'illustration',
    'canva design',
    'packaging design',
    'presentation design',
    'flutter development',
    'mobile app development',
    'android development',
    'web development',
    'frontend development',
    'backend development',
    'firebase integration',
    'supabase integration',
    'ui implementation',
    'api integration',
    'bug fixing',
    'website redesign',
    'portfolio website',
    'ecommerce website',
    'wordpress',
    'shopify',
    'react development',
    'digital marketing',
    'social media marketing',
    'facebook ads',
    'instagram marketing',
    'seo',
    'content marketing',
    'email marketing',
    'brand promotion',
    'lead generation',
    'marketing strategy',
    'youtube marketing',
    'tiktok marketing',
    'social media management',
    'virtual assistant',
    'business consultation',
    'project management',
    'customer support',
    'data entry',
    'market research',
    'business planning',
    'administrative support',
    'appointment scheduling',
    'operations support',
    'freelance consulting',
    'handicrafts',
    'artwork',
    'painting',
    'calligraphy',
    'handmade gifts',
    'paper crafts',
    'jewelry making',
    'resin art',
    'wood crafts',
    'decor items',
    'custom gifts',
    'home decor',
    'drawing',
    'sketching',
    'photography',
    'product photography',
    'photo editing',
    'video editing',
    'reels editing',
    'short videos',
    'youtube editing',
    'voice over',
    'podcast editing',
    'animation',
    'content creation',
    'ugc content',
    'professional',
    'creative',
    'custom',
    'beginner',
    'expert',
    'freelance',
    'remote work',
    'online work',
    'consultation',
    'services',
    'support',
    'delivery',
    'revision',
    'quality work',
  ];

  static const harmfulGigKeywords = [
    'hacking',
    'cracking',
    'ddos',
    'malware',
    'phishing',
    'fake passport',
    'fake id',
    'adult services',
    'escort',
    'porn',
    'drugs',
    'weapons',
    'terrorism',
    'money laundering',
    'fake reviews',
    'bot followers',
    'account stealing',
    'carding',
    'scam',
    'fraud',
  ];

  static final Set<String> _ignoredFieldNames = {
    'id',
    'user_id',
    'userid',
    'client_id',
    'clientid',
    'mentor_id',
    'mentorid',
    'sender_id',
    'senderid',
    'receiver_id',
    'receiverid',
    'conversation_id',
    'conversationid',
    'project_id',
    'projectid',
    'course_id',
    'courseid',
    'payment_id',
    'paymentid',
    'email',
    'photo_url',
    'photourl',
    'avatar',
    'sender_avatar',
    'url',
    'thumbnail_url',
    'video_url',
    'file_url',
    'fileurl',
    'created_at',
    'createdat',
    'updated_at',
    'updatedat',
    'deadline',
    'status',
    'type',
  };

  static final List<_ModerationRule> _rules = [
    _ModerationRule('drugs', 'drugs', 'high'),
    _ModerationRule('narcotics', 'drugs', 'high'),
    _ModerationRule('cocaine', 'drugs', 'high'),
    _ModerationRule('heroin', 'drugs', 'high'),
    _ModerationRule('meth', 'drugs', 'high'),
    _ModerationRule('marijuana sale', 'drugs', 'high'),
    _ModerationRule('weed delivery', 'drugs', 'high'),
    _ModerationRule('ecstasy', 'drugs', 'high'),
    _ModerationRule('lsd', 'drugs', 'high'),
    _ModerationRule('fentanyl', 'drugs', 'high'),
    _ModerationRule('illegal drugs', 'drugs', 'high'),
    _ModerationRule('drug trafficking', 'drugs', 'critical'),
    _ModerationRule('sell drugs', 'drugs', 'critical'),
    _ModerationRule('buy drugs', 'drugs', 'critical'),
    _ModerationRule('alcohol sales', 'regulated-goods', 'high'),
    _ModerationRule('alcoholic sales', 'regulated-goods', 'high'),
    _ModerationRule('liquor sales', 'regulated-goods', 'high'),
    _ModerationRule('weapon', 'weapons', 'high'),
    _ModerationRule('weapons', 'weapons', 'high'),
    _ModerationRule('gun for sale', 'weapons', 'critical'),
    _ModerationRule('firearm', 'weapons', 'high'),
    _ModerationRule('ak-47', 'weapons', 'critical'),
    _ModerationRule('pistol', 'weapons', 'high'),
    _ModerationRule('ammunition', 'weapons', 'high'),
    _ModerationRule('bomb making', 'weapons', 'critical'),
    _ModerationRule('explosive', 'weapons', 'critical'),
    _ModerationRule('explosives', 'weapons', 'critical'),
    _ModerationRule('grenade', 'weapons', 'critical'),
    _ModerationRule('sniper', 'weapons', 'high'),
    _ModerationRule('hitman', 'weapons', 'critical'),
    _ModerationRule('assassination', 'weapons', 'critical'),
    _ModerationRule('weapon trafficking', 'weapons', 'critical'),
    _ModerationRule('hack', 'cybercrime', 'high'),
    _ModerationRule('hacking', 'cybercrime', 'high'),
    _ModerationRule('hacking service', 'cybercrime', 'high'),
    _ModerationRule('hack account', 'cybercrime', 'high'),
    _ModerationRule('facebook hack', 'cybercrime', 'high'),
    _ModerationRule('instagram hack', 'cybercrime', 'high'),
    _ModerationRule('whatsapp hack', 'cybercrime', 'high'),
    _ModerationRule('email hack', 'cybercrime', 'high'),
    _ModerationRule('phishing', 'cybercrime', 'critical'),
    _ModerationRule('malware', 'cybercrime', 'critical'),
    _ModerationRule('ransomware', 'cybercrime', 'critical'),
    _ModerationRule('spyware', 'cybercrime', 'critical'),
    _ModerationRule('ddos', 'cybercrime', 'critical'),
    _ModerationRule('ddos attack', 'cybercrime', 'critical'),
    _ModerationRule('bypass otp', 'cybercrime', 'critical'),
    _ModerationRule('cracking', 'cybercrime', 'critical'),
    _ModerationRule('crack software', 'cybercrime', 'critical'),
    _ModerationRule('stolen credentials', 'cybercrime', 'critical'),
    _ModerationRule('account stealing', 'cybercrime', 'critical'),
    _ModerationRule('keylogger', 'cybercrime', 'critical'),
    _ModerationRule('carding', 'cybercrime', 'critical'),
    _ModerationRule('fraud', 'fraud', 'high'),
    _ModerationRule('scam', 'fraud', 'high'),
    _ModerationRule('fake documents', 'fraud', 'high'),
    _ModerationRule('fake passport', 'fraud', 'critical'),
    _ModerationRule('forged passport', 'fraud', 'critical'),
    _ModerationRule('fake id', 'fraud', 'critical'),
    _ModerationRule('fake cnic', 'fraud', 'critical'),
    _ModerationRule('fake degree', 'fraud', 'high'),
    _ModerationRule('fake identity', 'fraud', 'critical'),
    _ModerationRule('fake identities', 'fraud', 'critical'),
    _ModerationRule('identity theft', 'fraud', 'critical'),
    _ModerationRule('money laundering', 'fraud', 'critical'),
    _ModerationRule('ponzi scheme', 'fraud', 'critical'),
    _ModerationRule('scam investment', 'fraud', 'high'),
    _ModerationRule('crypto scam', 'fraud', 'high'),
    _ModerationRule('fake reviews', 'fraud', 'high'),
    _ModerationRule('fake followers', 'fraud', 'high'),
    _ModerationRule('bot followers', 'fraud', 'high'),
    _ModerationRule('bot traffic', 'fraud', 'high'),
    _ModerationRule('escort', 'adult', 'high'),
    _ModerationRule('prostitution', 'adult', 'critical'),
    _ModerationRule('nude content', 'adult', 'high'),
    _ModerationRule('explicit content', 'adult', 'high'),
    _ModerationRule('adult services', 'adult', 'high'),
    _ModerationRule('sexual services', 'adult', 'critical'),
    _ModerationRule('sex services', 'adult', 'critical'),
    _ModerationRule('s3x services', 'adult', 'critical'),
    _ModerationRule('webcam sex', 'adult', 'critical'),
    _ModerationRule('porn', 'adult', 'high'),
    _ModerationRule('pornography', 'adult', 'high'),
    _ModerationRule('onlyfans management', 'adult', 'high'),
    _ModerationRule('erotic chat', 'adult', 'high'),
    _ModerationRule('hate speech', 'hate', 'critical'),
    _ModerationRule('racial hatred', 'hate', 'critical'),
    _ModerationRule('white supremacy', 'hate', 'critical'),
    _ModerationRule('nazi propaganda', 'hate', 'critical'),
    _ModerationRule('extremist content', 'extremism', 'critical'),
    _ModerationRule('terrorism', 'terrorism', 'critical'),
    _ModerationRule('terrorist support', 'terrorism', 'critical'),
    _ModerationRule('isis support', 'terrorism', 'critical'),
    _ModerationRule('violence', 'violence', 'high'),
    _ModerationRule('threat', 'violence', 'high'),
    _ModerationRule('threats', 'violence', 'high'),
    _ModerationRule('animal abuse', 'violence', 'critical'),
    _ModerationRule('torture', 'violence', 'critical'),
    _ModerationRule('murder service', 'violence', 'critical'),
    _ModerationRule('self-harm promotion', 'violence', 'critical'),
    _ModerationRule('suicide encouragement', 'violence', 'critical'),
    _ModerationRule('child abuse', 'child-safety', 'critical'),
    _ModerationRule('child exploitation', 'child-safety', 'critical'),
    _ModerationRule('underage content', 'child-safety', 'critical'),
    _ModerationRule('minor sexual content', 'child-safety', 'critical'),
    _ModerationRule('fake medical certificate', 'medical', 'critical'),
    _ModerationRule('fake prescription', 'medical', 'critical'),
    _ModerationRule('miracle cure', 'medical', 'high'),
    _ModerationRule('guaranteed cancer cure', 'medical', 'critical'),
    _ModerationRule('illegal medicine', 'medical', 'critical'),
    _ModerationRule('prescription drugs', 'medical', 'high'),
    _ModerationRule('academic cheating', 'academic', 'critical'),
    _ModerationRule('impersonation exam', 'academic', 'critical'),
    _ModerationRule('take exam for me', 'academic', 'critical'),
    _ModerationRule('plagiarism service', 'academic', 'critical'),
    _ModerationRule('sell thesis', 'academic', 'critical'),
    _ModerationRule('fake visa', 'fraud', 'critical'),
    _ModerationRule('fake immigration papers', 'fraud', 'critical'),
    _ModerationRule('illegal marketplace', 'illegal-marketplace', 'critical'),
    _ModerationRule('illegal marketplaces', 'illegal-marketplace', 'critical'),
    _ModerationRule('black market', 'illegal-marketplace', 'critical'),
    _ModerationRule('piracy', 'piracy', 'high'),
    _ModerationRule('copyright violation', 'piracy', 'high'),
    _ModerationRule('pirated software', 'piracy', 'high'),
  ];

  bool isAllowedText(String text) => findMatchInText(text) == null;

  void validateText(String text) {
    final match = findMatchInText(text);
    if (match != null) throw ContentPolicyViolation(match);
  }

  void validateFields(Iterable<String?> fields) {
    final match = findMatchInFields(fields);
    if (match != null) throw ContentPolicyViolation(match);
  }

  void validatePayload(Map<String, dynamic> payload) {
    final match = findMatchInPayload(payload);
    if (match != null) throw ContentPolicyViolation(match);
  }

  ModerationMatch? findMatchInFields(Iterable<String?> fields) {
    for (final field in fields) {
      final value = field?.trim() ?? '';
      if (value.isEmpty) continue;
      final match = findMatchInText(value);
      if (match != null) return match;
    }
    return null;
  }

  ModerationMatch? findMatchInPayload(Map<String, dynamic> payload) {
    return _findMatchInValue(payload);
  }

  void validateGigFields({
    String? title,
    String? description,
    List<String>? skills,
    String? category,
    String? experienceLevel,
    List<Map<String, dynamic>>? packages,
  }) async {
    final fields = <String?>[
      title,
      description,
      category,
      experienceLevel,
      if (skills != null) ...skills,
    ];

    if (packages != null) {
      for (final pkg in packages) {
        fields
          ..add(pkg['name']?.toString())
          ..add(pkg['description']?.toString());
      }
    }

    validateFields(fields);
  }

  ModerationMatch? findMatchInText(String text) {
    final lower = text.toLowerCase();
    final tokens = _tokenizeForFuzzy(lower);

    for (final rule in _rules) {
      if (rule.keywordRegex.hasMatch(lower)) return rule.toMatch();
      if (rule.obfuscatedRegex.hasMatch(lower)) return rule.toMatch();
    }

    if (containsSafeGigKeyword(lower)) return null;

    for (final rule in _rules) {
      if (_hasFuzzyTokenMatch(tokens, rule)) return rule.toMatch();
    }

    return null;
  }

  bool containsSafeGigKeyword(String text) {
    final lower = text.toLowerCase();
    return safeGigKeywords.any((keyword) => _containsKeyword(lower, keyword));
  }

  bool containsHarmfulGigKeyword(String text) {
    final lower = text.toLowerCase();
    return harmfulGigKeywords.any(
      (keyword) => _containsKeyword(lower, keyword),
    );
  }

  ModerationMatch? _findMatchInValue(dynamic value, {String? key}) {
    if (value == null) return null;

    if (key != null && _ignoredFieldNames.contains(_cleanKey(key))) {
      return null;
    }

    if (value is String) return findMatchInText(value);
    if (value is Iterable) {
      for (final item in value) {
        final match = _findMatchInValue(item);
        if (match != null) return match;
      }
      return null;
    }
    if (value is Map) {
      for (final entry in value.entries) {
        final match = _findMatchInValue(
          entry.value,
          key: entry.key?.toString(),
        );
        if (match != null) return match;
      }
    }
    return null;
  }

  bool _hasFuzzyTokenMatch(List<String> tokens, _ModerationRule rule) {
    if (rule.keyword.contains(' ')) {
      return false;
    }

    if (rule.normalizedKeyword.length <= 4) {
      return false;
    }

    for (final token in tokens) {
      if (token.length <= 4) continue;
      final distance = _levenshtein(token, rule.normalizedKeyword);
      final maxDistance = rule.normalizedKeyword.length <= 5 ? 1 : 2;
      if (distance <= maxDistance) return true;
    }
    return false;
  }

  List<String> _tokenizeForFuzzy(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[\s\W_]+'))
        .map(normalize)
        .where((token) => token.length >= 4)
        .toList();
  }

  String normalize(String text) => _normalizeForMatch(text);

  String _normalizeForMatch(String text) {
    final translated = _translateLeet(text.toLowerCase());
    return translated.replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  String _translateLeet(String text) {
    final translated = text
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('!', 'i')
        .replaceAll('|', 'i')
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('5', 's')
        .replaceAll('7', 't')
        .replaceAll('8', 'b')
        .replaceAll('9', 'g')
        .replaceAll('@', 'a')
        .replaceAll(r'$', 's')
        .replaceAll('*', '');
    return translated.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  }

  String _cleanKey(String key) {
    return key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }

  bool _containsKeyword(String text, String keyword) {
    final pattern = _ModerationRule._buildKeywordRegex(keyword);
    return pattern.hasMatch(text);
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 0; i < a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0);
      current[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final insertCost = current[j] + 1;
        final deleteCost = previous[j + 1] + 1;
        final replaceCost = previous[j] + (a[i] == b[j] ? 0 : 1);
        current[j + 1] = [
          insertCost,
          deleteCost,
          replaceCost,
        ].reduce((value, element) => value < element ? value : element);
      }
      previous = current;
    }
    return previous[b.length];
  }
}

class _ModerationRule {
  final String keyword;
  final String category;
  final String severity;
  final String normalizedKeyword;
  final RegExp keywordRegex;
  final RegExp obfuscatedRegex;

  _ModerationRule(this.keyword, this.category, this.severity)
    : normalizedKeyword = ContentModerationService().normalize(keyword),
      keywordRegex = _buildKeywordRegex(keyword),
      obfuscatedRegex = _buildObfuscatedRegex(keyword);

  ModerationMatch toMatch() =>
      ModerationMatch(keyword: keyword, category: category, severity: severity);

  static RegExp _buildKeywordRegex(String keyword) {
    final escapedParts = keyword
        .toLowerCase()
        .trim()
        .split(RegExp(r'\s+'))
        .map(RegExp.escape)
        .join(r'[\s\W_]+');
    return RegExp(
      '(^|[^a-z0-9])$escapedParts(\$|[^a-z0-9])',
      caseSensitive: false,
    );
  }

  static RegExp _buildObfuscatedRegex(String keyword) {
    final map = <String, String>{
      'a': 'a@4',
      'b': 'b8',
      'c': 'c',
      'd': 'd',
      'e': 'e3',
      'f': 'f',
      'g': 'g9',
      'h': 'h',
      'i': 'i1!|',
      'j': 'j',
      'k': 'k',
      'l': 'l1|',
      'm': 'm',
      'n': 'n',
      'o': 'o0',
      'p': 'p',
      'q': 'q',
      'r': 'r',
      's': r's5$',
      't': 't7',
      'u': 'u',
      'v': 'v',
      'w': 'w',
      'x': 'x',
      'y': 'y',
      'z': 'z',
    };

    final buffer = StringBuffer();
    final lower = keyword.toLowerCase();
    for (var i = 0; i < lower.length; i++) {
      final ch = lower[i];
      if (RegExp(r'\s').hasMatch(ch)) {
        buffer.write(r'[\W_]+');
        continue;
      }
      if (RegExp(r'[a-z0-9]').hasMatch(ch)) {
        final chars = map[ch] ?? ch;
        buffer.write('[${RegExp.escape(chars)}]');
        buffer.write(r'[\W_]*');
        continue;
      }
      buffer.write(RegExp.escape(ch));
      buffer.write(r'[\W_]*');
    }

    return RegExp(
      '(^|[^a-z0-9])${buffer.toString()}(\$|[^a-z0-9])',
      caseSensitive: false,
    );
  }
}
