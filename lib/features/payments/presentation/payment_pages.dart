import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/status_views.dart';
import '../../appointments/data/appointment_models.dart';
import '../data/payment_models.dart';
import '../data/payment_repository.dart';

final _paymentRepository = PaymentRepository(apiClient: ApiClient());

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.appointment, this.repository});

  final Appointment appointment;
  final PaymentRepository? repository;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isSubmitting = false;
  String? _error;

  PaymentRepository get _repository => widget.repository ?? _paymentRepository;

  Future<void> _startPayment() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final session = await _repository.initiateSslCommerzPayment(
        widget.appointment.id,
      );
      final uri = Uri.tryParse(session.gatewayPageUrl);
      if (uri == null ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw const FormatException('The payment gateway URL is unavailable.');
      }
      if (mounted) {
        setState(
          () => _error = 'Payment opened in your browser. Return to appointments and verify the payment status there.',
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure payment')),
      body: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment for appointment',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTokens.spaceMd),
            Text(
              'Amount: BDT ${widget.appointment.paymentAmount ?? widget.appointment.doctor.consultationFee}',
            ),
            Text('Status: ${widget.appointment.paymentStatus}'),
            const SizedBox(height: AppTokens.spaceMd),
            const Text(
              'You will be redirected to SSLCommerz. Payment status is confirmed by Docvexa after the server validates the gateway callback.',
            ),
            const SizedBox(height: AppTokens.spaceLg),
            if (_isSubmitting)
              const AppLoadingView(label: 'Starting secure payment'),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _startPayment,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Continue to SSLCommerz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key, this.repository});

  final PaymentRepository? repository;

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  late Future<PaymentListResult> _future;

  PaymentRepository get _repository => widget.repository ?? _paymentRepository;

  @override
  void initState() {
    super.initState();
    _future = _repository.getMyPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment history')),
      body: FutureBuilder<PaymentListResult>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView(label: 'Loading payments');
          }
          if (snapshot.hasError) {
            return AppErrorView(
              message: snapshot.error.toString(),
              onRetry: () =>
                  setState(() => _future = _repository.getMyPayments()),
            );
          }
          final result = snapshot.data;
          if (result == null || result.items.isEmpty) {
            return const AppEmptyView(
              title: 'No payments yet',
              message: 'Your payment history will appear here.',
              icon: Icons.payments_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            itemCount: result.items.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppTokens.spaceSm),
            itemBuilder: (context, index) {
              final payment = result.items[index];
              return ListTile(
                contentPadding: const EdgeInsets.all(AppTokens.spaceMd),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppTokens.border),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                title: Text(
                  'BDT ${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${payment.method} · ${payment.status}\n${payment.transactionId}',
                ),
                isThreeLine: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PaymentDetailsPage(
                      paymentId: payment.id,
                      repository: _repository,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PaymentDetailsPage extends StatelessWidget {
  const PaymentDetailsPage({
    super.key,
    required this.paymentId,
    required this.repository,
  });

  final String paymentId;
  final PaymentRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment details')),
      body: FutureBuilder<Payment>(
        future: repository.getPaymentById(paymentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }
          if (snapshot.hasError) {
            return AppErrorView(
              message: snapshot.error.toString(),
              onRetry: () {},
            );
          }
          final payment = snapshot.data;
          if (payment == null) {
            return const AppEmptyView(
              title: 'Payment unavailable',
              message: 'This payment could not be found.',
            );
          }
          return Padding(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BDT ${payment.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTokens.spaceMd),
                Text('Status: ${payment.status}'),
                Text('Method: ${payment.method}'),
                Text('Transaction: ${payment.transactionId}'),
                if (payment.description.isNotEmpty)
                  Text('Description: ${payment.description}'),
                if (payment.rejectionReason.isNotEmpty)
                  Text('Reason: ${payment.rejectionReason}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
