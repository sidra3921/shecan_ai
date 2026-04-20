import 'package:shared_preferences/shared_preferences.dart';

class SavedMentorService {
  static final SavedMentorService _instance = SavedMentorService._internal();
  factory SavedMentorService() => _instance;
  SavedMentorService._internal();

  String _key(String userId) => 'saved_mentor_ids_$userId';

  Future<Set<String>> getSavedMentorIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key(userId)) ?? const <String>[];
    return values.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
  }

  Future<bool> isMentorSaved({
    required String userId,
    required String mentorId,
  }) async {
    final ids = await getSavedMentorIds(userId);
    return ids.contains(mentorId);
  }

  Future<bool> toggleMentor({
    required String userId,
    required String mentorId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getSavedMentorIds(userId);

    final isSaved = ids.contains(mentorId);
    if (isSaved) {
      ids.remove(mentorId);
    } else {
      ids.add(mentorId);
    }

    await prefs.setStringList(_key(userId), ids.toList());
    return !isSaved;
  }
}
