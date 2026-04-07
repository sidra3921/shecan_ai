import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Submit a review
  Future<ReviewModel> submitReview({
    required String projectId,
    required String reviewerId,
    required String reviewedUserId,
    required double rating,
    required String comment,
    List<String>? tags,
    List<String>? attachmentUrls,
  }) async {
    try {
      // Verify reviewer actually worked on this project
      final project = await _firestore
          .collection('projects')
          .doc(projectId)
          .get();
      final projectData = project.data() as Map<String, dynamic>?;

      bool isVerified = false;
      if (projectData != null) {
        isVerified =
            projectData['clientId'] == reviewerId ||
            projectData['mentorId'] == reviewerId;
      }

      final docRef = _firestore.collection('reviews').doc();
      final review = ReviewModel(
        id: docRef.id,
        projectId: projectId,
        reviewerId: reviewerId,
        reviewedUserId: reviewedUserId,
        rating: rating,
        comment: comment,
        tags: tags ?? [],
        createdAt: DateTime.now(),
        verified: isVerified,
        fraudStatus: await _checkFraud(comment, rating),
        attachmentUrls: attachmentUrls ?? [],
      );

      await docRef.set(review.toMap());

      // Update user's rating
      await _updateUserRating(reviewedUserId);

      return review;
    } catch (e) {
      print('Error submitting review: $e');
      rethrow;
    }
  }

  /// Check for fraud indicators
  Future<String> _checkFraud(String comment, double rating) async {
    // Simple fraud detection heuristics
    // In production, use ML models or third-party services

    // Red flags
    final redFlags = <String>[];

    // Check comment length (too short might be fake)
    if (comment.length < 20) {
      redFlags.add('comment_too_short');
    }

    // Check for spam keywords
    final spamKeywords = ['click', 'buy', 'free', 'limited time', 'urgent'];
    if (spamKeywords.any(
      (keyword) => comment.toLowerCase().contains(keyword),
    )) {
      redFlags.add('spam_keywords');
    }

    // Check for extreme rating (5 stars or 1 star with generic comment)
    if ((rating == 5.0 || rating == 1.0) && comment.length < 50) {
      redFlags.add('extreme_rating_generic');
    }

    // If multiple red flags, flag for review
    if (redFlags.length >= 2) {
      return 'flagged';
    }

    return 'none';
  }

  /// Update user rating based on new review
  Future<void> _updateUserRating(String userId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('reviewedUserId', isEqualTo: userId)
          .where('fraudStatus', isNotEqualTo: 'verified_fake')
          .get();

      if (reviews.docs.isEmpty) return;

      final ratings = reviews.docs.map((doc) {
        return (doc.data()['rating'] as num).toDouble();
      }).toList();

      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

      await _firestore.collection('users').doc(userId).update({
        'rating': double.parse(averageRating.toStringAsFixed(2)),
        'totalReviews': reviews.docs.length,
      });
    } catch (e) {
      print('Error updating rating: $e');
    }
  }

  /// Get reviews for a user
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('reviewedUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting reviews: $e');
      return [];
    }
  }

  /// Flag review for moderation
  Future<void> flagReview({
    required String reviewId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'fraudStatus': 'flagged',
        'fraudReason': reason,
      });
    } catch (e) {
      print('Error flagging review: $e');
      rethrow;
    }
  }

  /// Verify review as legitimate (admin function)
  Future<void> verifyReviewAsLegitimate(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'fraudStatus': 'verified_legitimate',
        'fraudReason': null,
      });
    } catch (e) {
      print('Error verifying review: $e');
      rethrow;
    }
  }

  /// Mark review as fake (admin function)
  Future<void> markReviewAsFake(String reviewId) async {
    try {
      final review = await _firestore.collection('reviews').doc(reviewId).get();
      final reviewData = review.data() as Map<String, dynamic>;

      await _firestore.collection('reviews').doc(reviewId).update({
        'fraudStatus': 'verified_fake',
      });

      // Recalculate user rating excluding fake reviews
      await _updateUserRating(reviewData['reviewedUserId']);
    } catch (e) {
      print('Error marking as fake: $e');
      rethrow;
    }
  }

  /// Get flagged reviews (mod queue)
  Future<List<ReviewModel>> getFlaggedReviews() async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('fraudStatus', isEqualTo: 'flagged')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting flagged reviews: $e');
      return [];
    }
  }

  /// Mark review as helpful
  Future<void> markReviewHelpful(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'helpfulCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error marking helpful: $e');
    }
  }

  /// Get average rating for user
  Future<double> getUserAverageRating(String userId) async {
    try {
      final reviews = await getUserReviews(userId);
      if (reviews.isEmpty) return 0.0;

      final legitimateReviews = reviews
          .where((r) => r.fraudStatus != 'verified_fake')
          .toList();

      if (legitimateReviews.isEmpty) return 0.0;

      final total = legitimateReviews.fold<double>(
        0,
        (sum, review) => sum + review.rating,
      );

      return total / legitimateReviews.length;
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0.0;
    }
  }
}
