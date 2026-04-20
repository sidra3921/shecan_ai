import '../models/payment_model.dart';
import 'supabase_database_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final _db = SupabaseDatabaseService();

  Future<String> createPayment(PaymentModel payment) {
    return _db.createPayment(payment);
  }

  Stream<List<PaymentModel>> streamUserPayments(String userId) {
    return _db.streamUserPayments(userId);
  }

  Future<void> createPaymentIntent({required String projectId, required double amount}) async {
    // Backward-compatible shim for older call sites.
    // Use createPayment with explicit from/to user IDs for real payment records.
    throw UnimplementedError(
      'createPaymentIntent requires payer/payee context. Use createPayment(PaymentModel) instead.',
    );
  }
}
