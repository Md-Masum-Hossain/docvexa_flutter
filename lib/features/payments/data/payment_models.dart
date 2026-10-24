class Payment {
  const Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.method,
    required this.transactionId,
    required this.status,
    required this.paymentProof,
    required this.description,
    required this.rejectionReason,
    required this.createdAt,
    required this.appointment,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: _string(json['_id'] ?? json['id']),
      amount: json['amount'] is num ? (json['amount'] as num).toDouble() : 0,
      currency: _string(json['currency']),
      method: _string(json['method']),
      transactionId: _string(json['transactionId']),
      status: _string(json['status']),
      paymentProof: _string(json['paymentProof']),
      description: _string(json['description']),
      rejectionReason: _string(json['rejectionReason']),
      createdAt: _date(json['createdAt']),
      appointment: _map(json['appointment']),
    );
  }

  final String id;
  final double amount;
  final String currency;
  final String method;
  final String transactionId;
  final String status;
  final String paymentProof;
  final String description;
  final String rejectionReason;
  final DateTime? createdAt;
  final Map<String, dynamic> appointment;
}

class PaymentListResult {
  const PaymentListResult({required this.items, required this.pagination});

  factory PaymentListResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['data'];
    return PaymentListResult(
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(Payment.fromJson)
                .toList()
          : const [],
      pagination: PaymentPagination.fromJson(_map(json['pagination'])),
    );
  }

  final List<Payment> items;
  final PaymentPagination pagination;
}

class PaymentPagination {
  const PaymentPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaymentPagination.fromJson(Map<String, dynamic> json) {
    return PaymentPagination(
      page: _int(json['page']),
      limit: _int(json['limit']),
      total: _int(json['total']),
      totalPages: _int(json['totalPages']),
    );
  }

  final int page;
  final int limit;
  final int total;
  final int totalPages;
}

class SslCommerzPaymentSession {
  const SslCommerzPaymentSession({
    required this.appointmentId,
    required this.transactionId,
    required this.gatewayPageUrl,
    required this.paymentAmount,
    required this.currency,
  });

  factory SslCommerzPaymentSession.fromJson(Map<String, dynamic> json) {
    return SslCommerzPaymentSession(
      appointmentId: _string(
        json['appointment'] is Map
            ? _map(json['appointment'])['_id']
            : json['appointment'],
      ),
      transactionId: _string(json['transactionId']),
      gatewayPageUrl: _string(json['gatewayPageURL'] ?? json['gatewayPageUrl']),
      paymentAmount: json['paymentAmount'] is num
          ? (json['paymentAmount'] as num).toDouble()
          : 0,
      currency: _string(json['currency']),
    );
  }

  final String appointmentId;
  final String transactionId;
  final String gatewayPageUrl;
  final double paymentAmount;
  final String currency;
}

String _string(Object? value) => value is String ? value : '';

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

int _int(Object? value) => value is num ? value.toInt() : 0;

Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : const {};
