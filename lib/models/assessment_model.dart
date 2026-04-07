import 'package:cloud_firestore/cloud_firestore.dart';

class SkillAssessment {
  final String id;
  final String skillName;
  final String description;
  final int totalQuestions;
  final int difficulty;
  final int passingScore;
  final DateTime createdAt;

  SkillAssessment({
    required this.id,
    required this.skillName,
    required this.description,
    required this.totalQuestions,
    required this.difficulty,
    required this.passingScore,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'skillName': skillName,
      'description': description,
      'totalQuestions': totalQuestions,
      'difficulty': difficulty,
      'passingScore': passingScore,
      'createdAt': createdAt,
    };
  }

  factory SkillAssessment.fromMap(Map<String, dynamic> map, String docId) {
    return SkillAssessment(
      id: docId,
      skillName: map['skillName'] ?? '',
      description: map['description'] ?? '',
      totalQuestions: map['totalQuestions'] ?? 0,
      difficulty: map['difficulty'] ?? 1,
      passingScore: map['passingScore'] ?? 70,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AssessmentQuestion {
  final String id;
  final String skillAssessmentId;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final int points;

  AssessmentQuestion({
    required this.id,
    required this.skillAssessmentId,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.points = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'skillAssessmentId': skillAssessmentId,
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'points': points,
    };
  }

  factory AssessmentQuestion.fromMap(Map<String, dynamic> map, String docId) {
    return AssessmentQuestion(
      id: docId,
      skillAssessmentId: map['skillAssessmentId'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? '',
      points: map['points'] ?? 1,
    );
  }
}

class AssessmentResult {
  final String id;
  final String userId;
  final String skillAssessmentId;
  final String skillName;
  final int totalQuestions;
  final int questionsAnswered;
  final int correctAnswers;
  final double scorePercentage;
  final bool passed;
  final DateTime completedAt;
  final int timeSpentSeconds;
  final String badge;

  AssessmentResult({
    required this.id,
    required this.userId,
    required this.skillAssessmentId,
    required this.skillName,
    required this.totalQuestions,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.passed,
    required this.completedAt,
    required this.timeSpentSeconds,
    required this.badge,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'skillAssessmentId': skillAssessmentId,
      'skillName': skillName,
      'totalQuestions': totalQuestions,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
      'scorePercentage': scorePercentage,
      'passed': passed,
      'completedAt': completedAt,
      'timeSpentSeconds': timeSpentSeconds,
      'badge': badge,
    };
  }

  factory AssessmentResult.fromMap(Map<String, dynamic> map, String docId) {
    return AssessmentResult(
      id: docId,
      userId: map['userId'] ?? '',
      skillAssessmentId: map['skillAssessmentId'] ?? '',
      skillName: map['skillName'] ?? '',
      totalQuestions: map['totalQuestions'] ?? 0,
      questionsAnswered: map['questionsAnswered'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      scorePercentage: (map['scorePercentage'] as num?)?.toDouble() ?? 0.0,
      passed: map['passed'] ?? false,
      completedAt:
          (map['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSpentSeconds: map['timeSpentSeconds'] ?? 0,
      badge: map['badge'] ?? 'bronze',
    );
  }
}
