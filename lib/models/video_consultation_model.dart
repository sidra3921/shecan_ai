
class VideoConsultation {
  final String id;
  final String mentorId;
  final String clientId;
  final String mentorName;
  final String clientName;
  final DateTime scheduledTime;
  final int durationMinutes;
  final double pricePerMinute;
  final double totalPrice;
  final String status; // 'scheduled', 'ongoing', 'completed', 'cancelled'
  final String? roomToken;
  final String? roomId;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? recordingUrl;
  final double rating;
  final String? feedback;

  VideoConsultation({
    required this.id,
    required this.mentorId,
    required this.clientId,
    required this.mentorName,
    required this.clientName,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.pricePerMinute,
    required this.totalPrice,
    this.status = 'scheduled',
    this.roomToken,
    this.roomId,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.recordingUrl,
    this.rating = 0.0,
    this.feedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'mentorId': mentorId,
      'clientId': clientId,
      'mentorName': mentorName,
      'clientName': clientName,
      'scheduledTime': scheduledTime,
      'durationMinutes': durationMinutes,
      'pricePerMinute': pricePerMinute,
      'totalPrice': totalPrice,
      'status': status,
      'roomToken': roomToken,
      'roomId': roomId,
      'createdAt': createdAt,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'recordingUrl': recordingUrl,
      'rating': rating,
      'feedback': feedback,
    };
  }

  factory VideoConsultation.fromMap(Map<String, dynamic> map, String docId) {
    return VideoConsultation(
      id: docId,
      mentorId: map['mentorId'] ?? '',
      clientId: map['clientId'] ?? '',
      mentorName: map['mentorName'] ?? '',
      clientName: map['clientName'] ?? '',
      scheduledTime: _parseDateTime(map['scheduledTime']) ?? DateTime.now(),
      durationMinutes: map['durationMinutes'] ?? 30,
      pricePerMinute: (map['pricePerMinute'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'scheduled',
      roomToken: map['roomToken'],
      roomId: map['roomId'],
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      startedAt: map['startedAt'] != null ? _parseDateTime(map['startedAt']) : null,
      endedAt: map['endedAt'] != null ? _parseDateTime(map['endedAt']) : null,
      recordingUrl: map['recordingUrl'],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      feedback: map['feedback'],
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

class ConsultationAvailability {
  final String id;
  final String mentorId;
  final String dayOfWeek; // 'monday', 'tuesday', etc.
  final String startTime; // 'HH:mm' format
  final String endTime;
  final bool isAvailable;

  ConsultationAvailability({
    required this.id,
    required this.mentorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'mentorId': mentorId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }

  factory ConsultationAvailability.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return ConsultationAvailability(
      id: docId,
      mentorId: map['mentorId'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}
