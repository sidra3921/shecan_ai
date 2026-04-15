class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  Future<void> submitReview({required String projectId, required String reviewedUserId, required double rating, required String comment}) async {}
}
