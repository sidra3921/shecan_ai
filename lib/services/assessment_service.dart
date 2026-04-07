import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessment_model.dart';

class AssessmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all available skill assessments
  Future<List<SkillAssessment>> getAvailableAssessments() async {
    try {
      final snapshot = await _firestore.collection('assessments').get();
      return snapshot.docs
          .map((doc) => SkillAssessment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting assessments: $e');
      return [];
    }
  }

  /// Get assessment questions
  Future<List<AssessmentQuestion>> getAssessmentQuestions(
    String assessmentId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('assessments')
          .doc(assessmentId)
          .collection('questions')
          .get();

      return snapshot.docs
          .map((doc) => AssessmentQuestion.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting questions: $e');
      return [];
    }
  }

  /// Submit assessment and calculate result
  Future<AssessmentResult> submitAssessment({
    required String userId,
    required String assessmentId,
    required List<MapEntry<String, String>>
    answers, // questionId -> selectedAnswer
    required int timeSpentSeconds,
  }) async {
    try {
      // Get assessment details
      final assessment = await _firestore
          .collection('assessments')
          .doc(assessmentId)
          .get();
      final assessmentData = assessment.data() as Map<String, dynamic>;

      // Get correct answers
      final questions = await getAssessmentQuestions(assessmentId);

      int correctAnswers = 0;
      for (final answer in answers) {
        final question = questions.firstWhere(
          (q) => q.id == answer.key,
          orElse: () => AssessmentQuestion(
            id: '',
            skillAssessmentId: '',
            questionText: '',
            options: [],
            correctAnswer: '',
          ),
        );

        if (question.id.isNotEmpty && answer.value == question.correctAnswer) {
          correctAnswers++;
        }
      }

      final scorePercentage = (correctAnswers / questions.length) * 100;
      final passingScore = assessmentData['passingScore'] as int? ?? 70;
      final passed = scorePercentage >= passingScore;

      // Determine badge
      String badge = 'bronze';
      if (scorePercentage >= 90)
        badge = 'platinum';
      else if (scorePercentage >= 80)
        badge = 'gold';
      else if (scorePercentage >= 70)
        badge = 'silver';

      // Save result
      final resultRef = _firestore.collection('assessmentResults').doc();
      final result = AssessmentResult(
        id: resultRef.id,
        userId: userId,
        skillAssessmentId: assessmentId,
        skillName: assessmentData['skillName'] ?? '',
        totalQuestions: questions.length,
        questionsAnswered: answers.length,
        correctAnswers: correctAnswers,
        scorePercentage: scorePercentage,
        passed: passed,
        completedAt: DateTime.now(),
        timeSpentSeconds: timeSpentSeconds,
        badge: badge,
      );

      await resultRef.set(result.toMap());

      // Update user's skills if passed
      if (passed) {
        await _updateUserSkill(
          userId: userId,
          skillName: assessmentData['skillName'],
          badge: badge,
        );
      }

      return result;
    } catch (e) {
      print('Error submitting assessment: $e');
      rethrow;
    }
  }

  /// Update user's verified skills
  Future<void> _updateUserSkill({
    required String userId,
    required String skillName,
    required String badge,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'verifiedSkills': FieldValue.arrayUnion([
          {'name': skillName, 'badge': badge, 'verifiedAt': DateTime.now()},
        ]),
      });
    } catch (e) {
      print('Error updating user skills: $e');
    }
  }

  /// Get user's assessment results
  Future<List<AssessmentResult>> getUserResults(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('assessmentResults')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AssessmentResult.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting user results: $e');
      return [];
    }
  }

  /// Get user's verified badge count
  Future<Map<String, int>> getUserBadgeCounts(String userId) async {
    try {
      final results = await getUserResults(userId);
      final passed = results.where((r) => r.passed);

      return {
        'total': passed.length,
        'platinum': passed.where((r) => r.badge == 'platinum').length,
        'gold': passed.where((r) => r.badge == 'gold').length,
        'silver': passed.where((r) => r.badge == 'silver').length,
        'bronze': passed.where((r) => r.badge == 'bronze').length,
      };
    } catch (e) {
      print('Error getting badge counts: $e');
      return {};
    }
  }

  /// Check if user passed assessment for a skill
  Future<bool> hasPassedAssessment({
    required String userId,
    required String skillName,
  }) async {
    try {
      final results = await _firestore
          .collection('assessmentResults')
          .where('userId', isEqualTo: userId)
          .where('skillName', isEqualTo: skillName)
          .where('passed', isEqualTo: true)
          .limit(1)
          .get();

      return results.docs.isNotEmpty;
    } catch (e) {
      print('Error checking assessment: $e');
      return false;
    }
  }
}
