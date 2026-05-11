import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../config/app_config.dart';
import '../../constants/app_colors.dart';
import '../../services/payment_gateway_service.dart';
import '../../services/payment_service.dart';
import '../../services/supabase_database_service.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  const PaymentCheckoutScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.fromUserId,
    required this.toUserId,
    required this.itemType,
    this.projectId,
    this.courseId,
  });

  final String title;
  final double amount;
  final String fromUserId;
  final String toUserId;
  final String itemType;
  final String? projectId;
  final String? courseId;

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  PaymentMethod _method = PaymentMethod.jazzcash;
  bool _isProcessing = false;

  final _paymentService = PaymentService();
  final _gateway = PaymentGatewayService();
  final _db = GetIt.instance<SupabaseDatabaseService>();

  String _buildReference(PaymentMethod method) {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return 'sandbox_${method.methodValue}_$stamp';
  }

  Future<void> _startPayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final reference = _buildReference(_method);
      final paymentId = await _paymentService.createEscrowPayment(
        projectId: widget.projectId,
        courseId: widget.courseId,
        fromUserId: widget.fromUserId,
        toUserId: widget.toUserId,
        amount: widget.amount,
        method: _method.methodValue,
        itemType: widget.itemType,
        escrowReference: reference,
      );

      final redirectUrl = await _gateway.buildRedirectUrl(
        method: _method,
        paymentId: paymentId,
        amount: widget.amount,
        currency: AppConfig.currencyCode,
        itemLabel: widget.title,
      );

      await _gateway.openRedirectUrl(redirectUrl);
      final confirmed = await _gateway.confirmCompletion(context, _method);

      if (confirmed) {
        await _db.update('payments', paymentId, {
          'status': 'pending',
          'escrow_status': 'held',
          'escrow_reference': reference,
          'method': _method.methodValue,
        });

        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      }

      await _db.update('payments', paymentId, {
        'status': 'failed',
        'escrow_status': 'pending',
        'escrow_reference': reference,
        'method': _method.methodValue,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment not completed yet.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _methodTile(PaymentMethod method, String subtitle) {
    return InkWell(
      onTap: _isProcessing ? null : () => setState(() => _method = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _method == method ? AppColors.primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Radio<PaymentMethod>(
              value: method,
              groupValue: _method,
              onChanged: _isProcessing ? null : (value) {
                if (value != null) setState(() => _method = value);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Amount: Rs ${widget.amount.toStringAsFixed(0)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Escrow: Funds held until client approval.',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _methodTile(
            PaymentMethod.jazzcash,
            'Redirect to JazzCash sandbox',
          ),
          _methodTile(
            PaymentMethod.easypaisa,
            'Redirect to EasyPaisa sandbox',
          ),
          _methodTile(
            PaymentMethod.card,
            'Stripe Checkout (sandbox)',
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isProcessing ? null : _startPayment,
            child: Text(_isProcessing ? 'Processing...' : 'Continue to Pay'),
          ),
        ],
      ),
    );
  }
}
