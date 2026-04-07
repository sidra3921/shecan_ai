import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String projectId;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final String status; // 'pending', 'completed', 'failed'
  final String method;
  final DateTime createdAt;
  final String? stripePaymentIntentId;
  final String? receiptUrl;

  PaymentModel({
    required this.id,
    required this.projectId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    this.status = 'pending',
    this.method = 'card',
    DateTime? createdAt,
    this.stripePaymentIntentId,
    this.receiptUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'status': status,
      'method': method,
      'createdAt': Timestamp.fromDate(createdAt),
      'stripePaymentIntentId': stripePaymentIntentId,
      'receiptUrl': receiptUrl,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      id: id,
      projectId: map['projectId'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      method: map['method'] ?? 'card',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      stripePaymentIntentId: map['stripePaymentIntentId'],
      receiptUrl: map['receiptUrl'],
    );
  }

  // Helper getter
  String get projectTitle => 'Project $projectId';
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
      lastUpdated:
          (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bankAccounts: List<String>.from(map['bankAccounts'] ?? []),
    );
  }
}
