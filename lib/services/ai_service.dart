class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  Future<Map<String, dynamic>> generateResume({required String userId}) async {
    return {
      'userId': userId,
      'summary': 'AI resume generation is available after backend integration.',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> getChatHistory({required String userId}) async {
    return [];
  }
}
