import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_consultation_model.dart';

class VideoConsultationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Note: Integrate with Twilio/Agora for actual video
  // For now, using placeholders

  /// Schedule a consultation
  Future<VideoConsultation> scheduleConsultation({
    required String mentorId,
    required String clientId,
    required String mentorName,
    required String clientName,
    required DateTime scheduledTime,
    required int durationMinutes,
    required double pricePerMinute,
  }) async {
    try {
      final docRef = _firestore.collection('consultations').doc();
      final totalPrice = durationMinutes * pricePerMinute;

      final consultation = VideoConsultation(
        id: docRef.id,
        mentorId: mentorId,
        clientId: clientId,
        mentorName: mentorName,
        clientName: clientName,
        scheduledTime: scheduledTime,
        durationMinutes: durationMinutes,
        pricePerMinute: pricePerMinute,
        totalPrice: totalPrice,
        createdAt: DateTime.now(),
      );

      await docRef.set(consultation.toMap());
      return consultation;
    } catch (e) {
      print('Error scheduling consultation: $e');
      rethrow;
    }
  }

  /// Get consultation by ID
  Future<VideoConsultation?> getConsultation(String consultationId) async {
    try {
      final doc = await _firestore
          .collection('consultations')
          .doc(consultationId)
          .get();
      if (doc.exists) {
        return VideoConsultation.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting consultation: $e');
      return null;
    }
  }

  /// Get upcoming consultations
  Future<List<VideoConsultation>> getUpcomingConsultations(
    String userId,
  ) async {
    try {
      final nowQuery = await _firestore
          .collection('consultations')
          .where('scheduledTime', isGreaterThan: DateTime.now())
          .where('status', isNotEqualTo: 'cancelled')
          .orderBy('scheduledTime')
          .get();

      return nowQuery.docs
          .where((doc) {
            final data = doc.data();
            return data['mentorId'] == userId || data['clientId'] == userId;
          })
          .map((doc) => VideoConsultation.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting consultations: $e');
      return [];
    }
  }

  /// Start consultation (generate room token)
  Future<String?> startConsultation(String consultationId) async {
    try {
      // In production, integrate with Twilio/Agora
      final roomToken =
          'token_$consultationId}_${DateTime.now().millisecondsSinceEpoch}';
      final roomId = 'room_$consultationId';

      await _firestore.collection('consultations').doc(consultationId).update({
        'status': 'ongoing',
        'startedAt': DateTime.now(),
        'roomToken': roomToken,
        'roomId': roomId,
      });

      return roomToken;
    } catch (e) {
      print('Error starting consultation: $e');
      return null;
    }
  }

  /// End consultation
  Future<void> endConsultation(String consultationId) async {
    try {
      await _firestore.collection('consultations').doc(consultationId).update({
        'status': 'completed',
        'endedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error ending consultation: $e');
      rethrow;
    }
  }

  /// Rate consultation
  Future<void> rateConsultation({
    required String consultationId,
    required double rating,
    required String feedback,
  }) async {
    try {
      await _firestore.collection('consultations').doc(consultationId).update({
        'rating': rating,
        'feedback': feedback,
      });
    } catch (e) {
      print('Error rating consultation: $e');
      rethrow;
    }
  }

  /// Set mentor availability
  Future<void> setAvailability({
    required String mentorId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final docRef = _firestore
          .collection('mentorAvailability')
          .doc('${mentorId}_$dayOfWeek');

      final availability = ConsultationAvailability(
        id: docRef.id,
        mentorId: mentorId,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      );

      await docRef.set(availability.toMap());
    } catch (e) {
      print('Error setting availability: $e');
      rethrow;
    }
  }

  /// Get mentor availability
  Future<List<ConsultationAvailability>> getMentorAvailability(
    String mentorId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('mentorAvailability')
          .where('mentorId', isEqualTo: mentorId)
          .where('isAvailable', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ConsultationAvailability.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting availability: $e');
      return [];
    }
  }

  /// Cancel consultation
  Future<void> cancelConsultation({
    required String consultationId,
    required String reason,
  }) async {
    try {
      final consultation = await getConsultation(consultationId);
      if (consultation == null) return;

      await _firestore.collection('consultations').doc(consultationId).update({
        'status': 'cancelled',
        'cancelReason': reason,
      });

      // Refund if payment was made
      // Integration with payment service needed
    } catch (e) {
      print('Error cancelling consultation: $e');
      rethrow;
    }
  }

  /// Get mentor's consultation history
  Future<List<VideoConsultation>> getMentorConsultationHistory(
    String mentorId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('consultations')
          .where('mentorId', isEqualTo: mentorId)
          .where('status', isEqualTo: 'completed')
          .orderBy('endedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => VideoConsultation.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting history: $e');
      return [];
    }
  }
}
