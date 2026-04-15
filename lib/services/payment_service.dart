class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  Future<void> createPaymentIntent({required String projectId, required double amount}) async {}
}
