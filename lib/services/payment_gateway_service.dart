import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';

enum PaymentMethod { jazzcash, easypaisa, card }

extension PaymentMethodLabels on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.jazzcash:
        return 'JazzCash';
      case PaymentMethod.easypaisa:
        return 'EasyPaisa';
      case PaymentMethod.card:
        return 'Card (Stripe)';
    }
  }

  String get methodValue {
    switch (this) {
      case PaymentMethod.jazzcash:
        return 'jazzcash';
      case PaymentMethod.easypaisa:
        return 'easypaisa';
      case PaymentMethod.card:
        return 'card';
    }
  }
}

class PaymentGatewayService {
  Future<Uri> buildRedirectUrl({
    required PaymentMethod method,
    required String paymentId,
    required double amount,
    required String currency,
    required String itemLabel,
  }) async {
    final baseUrl = switch (method) {
      PaymentMethod.jazzcash => AppConfig.jazzCashSandboxUrl,
      PaymentMethod.easypaisa => AppConfig.easyPaisaSandboxUrl,
      PaymentMethod.card => AppConfig.stripeCheckoutUrl,
    };

    final params = <String, String>{
      'amount': amount.toStringAsFixed(0),
      'currency': currency,
      'payment_id': paymentId,
      'item_label': itemLabel,
      'return_url': AppConfig.paymentReturnUrl,
      'cancel_url': AppConfig.paymentCancelUrl,
    };

    return Uri.parse(baseUrl).replace(queryParameters: params);
  }

  Future<void> openRedirectUrl(Uri url) async {
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok) {
      throw Exception('Could not open payment gateway.');
    }
  }

  Future<bool> confirmCompletion(BuildContext context, PaymentMethod method) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${method.label} Payment'),
        content: const Text(
          'After completing payment in the browser, return here to confirm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Paid'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('I Paid'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
