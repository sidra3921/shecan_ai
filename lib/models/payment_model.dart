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

  PaymentModel({
    required this.id,
    required this.projectId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    this.status = 'pending',
    this.method = 'card',
    DateTime? createdAt,
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
    );
  }
}
