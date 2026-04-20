import '../models/review_model.dart';
import 'supabase_auth_service.dart';
import 'supabase_database_service.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final _db = SupabaseDatabaseService();
  final _auth = SupabaseAuthService();

  Future<void> submitReview({
    required String projectId,
    required String reviewedUserId,
    required double rating,
    required String comment,
  }) async {
    final reviewerId = _auth.currentUserId;
    if (reviewerId == null) {
      throw Exception('No signed-in user to submit review');
    }

    final review = ReviewModel(
      id: '',
      projectId: projectId,
      reviewerId: reviewerId,
      reviewedUserId: reviewedUserId,
      rating: rating,
      comment: comment,
      verified: true,
    );
    await _db.createReview(review);
  }

  Future<List<ReviewModel>> getUserReviews(String userId) {
    return _db.getUserReviews(userId);
  }
}
