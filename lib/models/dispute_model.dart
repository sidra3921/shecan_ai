class DisputeModel {
  final String id;
  final String projectId;
  final String raisedBy;
  final String againstUser;
  final String reason;
  final String status; // 'open', 'in-progress', 'resolved'
  final List<String> participants;
  final List<Map<String, dynamic>> messages;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  DisputeModel({
    required this.id,
    required this.projectId,
    required this.raisedBy,
    required this.againstUser,
    required this.reason,
    this.status = 'open',
    List<String>? participants,
    this.messages = const [],
    DateTime? createdAt,
    this.resolvedAt,
  }) : participants = participants ?? [raisedBy, againstUser],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'raisedBy': raisedBy,
      'againstUser': againstUser,
      'reason': reason,
      'status': status,
      'participants': participants,
      'messages': messages,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory DisputeModel.fromMap(Map<String, dynamic> map, String id) {
    return DisputeModel(
      id: id,
      projectId: map['projectId'] ?? '',
      raisedBy: map['raisedBy'] ?? '',
      againstUser: map['againstUser'] ?? '',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'open',
      participants: List<String>.from(map['participants'] ?? []),
      messages: List<Map<String, dynamic>>.from(map['messages'] ?? []),
      createdAt: _parseDateTime(map['createdAt']),
      resolvedAt: _parseDateTime(map['resolvedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Helper getters
  String get projectTitle => 'Project $projectId';
  String get clientName => raisedBy;
  String get description => reason;
}
