import '../../../core/network/api_client.dart';
import 'payment_models.dart';

class PaymentRepository {
  const PaymentRepository({required this.apiClient, this.accessToken});

  final ApiClient apiClient;
  final String? accessToken;

  Future<PaymentListResult> getMyPayments({
    int page = 1,
    int limit = 10,
    String? status,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    if (status != null && status.isNotEmpty) query['status'] = status;
    final response = await apiClient.get(
      '/payments/my?${Uri(queryParameters: query).query}',
      accessToken: accessToken,
    );
    return PaymentListResult.fromJson(_unwrap(response));
  }

  Future<Payment> getPaymentById(String id) async {
    final response = await apiClient.get(
      '/payments/$id',
      accessToken: accessToken,
    );
    return Payment.fromJson(_unwrap(response));
  }

  Future<SslCommerzPaymentSession> initiateSslCommerzPayment(
    String appointmentId,
  ) async {
    final response = await apiClient.post(
      '/payments/sslcommerz/initiate',
      accessToken: accessToken,
      body: {'appointmentId': appointmentId},
    );
    return SslCommerzPaymentSession.fromJson(_unwrap(response));
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> response) {
    final data = response['data'];
    return data is Map<String, dynamic> ? data : response;
  }
}
