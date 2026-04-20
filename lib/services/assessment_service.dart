class AssessmentService {
  static final AssessmentService _instance = AssessmentService._internal();
  factory AssessmentService() => _instance;
  AssessmentService._internal();

  Future<List<Map<String, dynamic>>> getAssessments() async => [];
}
