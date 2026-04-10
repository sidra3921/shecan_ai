// Firestore removed - use SupabaseDatabaseService instead
import '../models/payment_model.dart';

class PaymentService {
  // FirebaseFirestore instance removed

  // NOTE: Add your Stripe keys to .env or environment
  // For production, use: https://pub.dev/packages/flutter_stripe
  static const String stripePublishableKey = 'pk_test_YOUR_KEY';
  static const String stripeSecretKey = 'sk_test_YOUR_KEY';

  /// Create a payment record
  Future<PaymentModel> createPayment({
    required String projectId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String method,
  }) async {
    try {
      final docRef = _firestore.collection('payments').doc();
      final payment = PaymentModel(
        id: docRef.id,
        projectId: projectId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        amount: amount,
        status: 'pending',
        method: method,
      );

      await docRef.set(payment.toMap());
      return payment;
    } catch (e) {
      print('Error creating payment: $e');
      rethrow;
    }
  }

  /// Process payment through Stripe
  /// In production, integrate with: https://pub.dev/packages/flutter_stripe
  Future<bool> processStripePayment({
    required String paymentId,
    required String stripeToken,
    required double amount,
    required String email,
  }) async {
    try {
      // This is a placeholder. In production:
      // 1. Use flutter_stripe package
      // 2. Create payment intent with backend
      // 3. Confirm payment with card token

      print('Processing Stripe payment: $paymentId');

      // Update payment status to completed
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'completed',
        'stripePaymentIntentId': 'pi_placeholder_$paymentId',
        'receiptUrl': 'https://dashboard.stripe.com/receipts/placeholder',
      });

      return true;
    } catch (e) {
      print('Error processing payment: $e');
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'failed',
      });
      return false;
    }
  }

  /// Get payment history
  Future<List<PaymentModel>> getPaymentHistory({
    required String userId,
    String? projectId,
  }) async {
    try {
      Query query = _firestore
          .collection('payments')
          .where('fromUserId', isEqualTo: userId);

      if (projectId != null) {
        query = query.where('projectId', isEqualTo: projectId);
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs
          .map(
            (doc) => PaymentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting payments: $e');
      return [];
    }
  }

  /// Get user wallet
  Future<Wallet> getUserWallet(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();

      if (doc.exists) {
        return Wallet.fromMap(doc.data() as Map<String, dynamic>);
      }

      // Create default wallet if doesn't exist
      final wallet = Wallet(
        userId: userId,
        totalEarnings: 0.0,
        availableBalance: 0.0,
        pendingBalance: 0.0,
        totalWithdrawn: 0.0,
        lastUpdated: DateTime.now(),
      );

      await _firestore.collection('wallets').doc(userId).set(wallet.toMap());
      return wallet;
    } catch (e) {
      print('Error getting wallet: $e');
      rethrow;
    }
  }

  /// Update wallet balance after payment
  Future<void> updateWalletBalance({
    required String userId,
    required double amount,
    required String type, // 'earn', 'withdraw', 'refund'
  }) async {
    try {
      final wallet = await getUserWallet(userId);

      double newAvailable = wallet.availableBalance;
      double newEarnings = wallet.totalEarnings;
      double newWithdrawn = wallet.totalWithdrawn;

      switch (type) {
        case 'earn':
          newEarnings += amount;
          newAvailable += amount;
          break;
        case 'withdraw':
          newAvailable -= amount;
          newWithdrawn += amount;
          break;
        case 'refund':
          newAvailable += amount;
          break;
      }

      await _firestore.collection('wallets').doc(userId).update({
        'totalEarnings': newEarnings,
        'availableBalance': newAvailable,
        'totalWithdrawn': newWithdrawn,
        'lastUpdated': DateTime.now(),
      });
    } catch (e) {
      print('Error updating wallet: $e');
      rethrow;
    }
  }

  /// Request withdrawal
  Future<void> requestWithdrawal({
    required String userId,
    required double amount,
    required String bankAccountId,
  }) async {
    try {
      // Create withdrawal record
      final withdrawalRef = _firestore.collection('withdrawals').doc();

      await withdrawalRef.set({
        'id': withdrawalRef.id,
        'userId': userId,
        'amount': amount,
        'bankAccountId': bankAccountId,
        'status': 'pending',
        'requestedAt': DateTime.now(),
        'processedAt': null,
      });

      // Deduct from available balance
      await updateWalletBalance(
        userId: userId,
        amount: amount,
        type: 'withdraw',
      );
    } catch (e) {
      print('Error requesting withdrawal: $e');
      rethrow;
    }
  }

  /// Get earnings summary
  Future<Map<String, double>> getEarningsSummary(String userId) async {
    try {
      final payments = await getPaymentHistory(userId: userId);

      double thisMonth = 0;
      double thisYear = 0;
      double allTime = 0;

      final now = DateTime.now();
      final thisMonthStart = DateTime(now.year, now.month, 1);
      final thisYearStart = DateTime(now.year, 1, 1);

      for (final payment in payments) {
        if (payment.status == 'completed') {
          allTime += payment.amount;

          if (payment.createdAt.isAfter(thisYearStart)) {
            thisYear += payment.amount;
          }

          if (payment.createdAt.isAfter(thisMonthStart)) {
            thisMonth += payment.amount;
          }
        }
      }

      return {'thisMonth': thisMonth, 'thisYear': thisYear, 'allTime': allTime};
    } catch (e) {
      print('Error getting earnings summary: $e');
      return {'thisMonth': 0, 'thisYear': 0, 'allTime': 0};
    }
  }

  /// Process refund
  Future<bool> processRefund({
    required String paymentId,
    required String reason,
  }) async {
    try {
      final payment = await _firestore
          .collection('payments')
          .doc(paymentId)
          .get();
      final paymentData = payment.data() as Map<String, dynamic>;

      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'refunded',
        'refundReason': reason,
        'refundedAt': DateTime.now(),
      });

      // Return money to payer
      await updateWalletBalance(
        userId: paymentData['fromUserId'],
        amount: paymentData['amount'] as double,
        type: 'refund',
      );

      return true;
    } catch (e) {
      print('Error processing refund: $e');
      return false;
    }
  }
}
