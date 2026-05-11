class PaymentModel {
  final String id;
  final String? projectId;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final String status; // 'pending', 'completed', 'failed'
  final String method;
  final DateTime createdAt;
  final String? stripePaymentIntentId;
  final String? receiptUrl;
  final String? escrowStatus; // 'pending', 'held', 'released', 'refunded'
  final DateTime? escrowHoldUntil;
  final DateTime? escrowReleasedAt;
  final String? escrowReference;
  final String? itemType; // 'service' or 'course'
  final String? courseId;
  final double? commissionRate;
  final double? commissionAmount;
  final double? payoutAmount;

  PaymentModel({
    required this.id,
    this.projectId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    this.status = 'pending',
    this.method = 'card',
    DateTime? createdAt,
    this.stripePaymentIntentId,
    this.receiptUrl,
    this.escrowStatus,
    this.escrowHoldUntil,
    this.escrowReleasedAt,
    this.escrowReference,
    this.itemType,
    this.courseId,
    this.commissionRate,
    this.commissionAmount,
    this.payoutAmount,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    final payload = <String, dynamic>{
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'amount': amount,
      'status': status,
      'method': method,
      'created_at': createdAt.toIso8601String(),
      'stripe_payment_intent_id': stripePaymentIntentId,
      'receipt_url': receiptUrl,
      'escrow_status': escrowStatus,
      'escrow_hold_until': escrowHoldUntil?.toIso8601String(),
      'escrow_released_at': escrowReleasedAt?.toIso8601String(),
      'escrow_reference': escrowReference,
      'item_type': itemType,
      'course_id': courseId,
      'commission_rate': commissionRate,
      'commission_amount': commissionAmount,
      'payout_amount': payoutAmount,
    };
    if (projectId != null && projectId!.isNotEmpty) {
      payload['project_id'] = projectId;
    }
    return payload;
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      id: id,
      projectId: (map['project_id'] ?? map['projectId'])?.toString(),
      fromUserId: map['from_user_id'] ?? map['fromUserId'] ?? '',
      toUserId: map['to_user_id'] ?? map['toUserId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      method: map['method'] ?? 'card',
      createdAt: _parseDateTime(map['created_at'] ?? map['createdAt']) ?? DateTime.now(),
      stripePaymentIntentId: map['stripe_payment_intent_id'] ?? map['stripePaymentIntentId'],
      receiptUrl: map['receipt_url'] ?? map['receiptUrl'],
      escrowStatus: map['escrow_status'] ?? map['escrowStatus'],
      escrowHoldUntil: _parseDateTime(map['escrow_hold_until'] ?? map['escrowHoldUntil']),
      escrowReleasedAt: _parseDateTime(map['escrow_released_at'] ?? map['escrowReleasedAt']),
      escrowReference: map['escrow_reference'] ?? map['escrowReference'],
      itemType: map['item_type'] ?? map['itemType'],
      courseId: map['course_id'] ?? map['courseId'],
      commissionRate: (map['commission_rate'] ?? map['commissionRate'])
          ?.toDouble(),
      commissionAmount: (map['commission_amount'] ?? map['commissionAmount'])
          ?.toDouble(),
      payoutAmount: (map['payout_amount'] ?? map['payoutAmount'])?.toDouble(),
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

  // Helper getter
  String get projectTitle =>
      projectId == null || projectId!.isEmpty ? 'Payment' : 'Project $projectId';
}

class Wallet {
  final String userId;
  final double totalEarnings;
  final double availableBalance;
  final double pendingBalance;
  final double totalWithdrawn;
  final DateTime lastUpdated;
  final List<String> bankAccounts;

  Wallet({
    required this.userId,
    required this.totalEarnings,
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalWithdrawn,
    required this.lastUpdated,
    this.bankAccounts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalEarnings': totalEarnings,
      'availableBalance': availableBalance,
      'pendingBalance': pendingBalance,
      'totalWithdrawn': totalWithdrawn,
      'lastUpdated': lastUpdated,
      'bankAccounts': bankAccounts,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      userId: map['userId'] ?? '',
      totalEarnings: (map['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (map['availableBalance'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (map['pendingBalance'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (map['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: PaymentModel._parseDateTime(map['lastUpdated']) ?? DateTime.now(),
      bankAccounts: List<String>.from(map['bankAccounts'] ?? []),
    );
  }
}
