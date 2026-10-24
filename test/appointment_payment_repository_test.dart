import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:docvexa/core/network/api_client.dart';
import 'package:docvexa/features/appointments/data/appointment_repository.dart';
import 'package:docvexa/features/payments/data/payment_repository.dart';

void main() {
  final doctor = {
    '_id': '507f1f77bcf86cd799439011',
    'specialization': 'Cardiology',
    'user': {'name': 'Amina Rahman', 'role': 'doctor'},
  };

  test('creates appointments with the confirmed backend fields', () async {
    final client = ApiClient(
      baseUrl: 'https://example.test/api/v1',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/appointments');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['doctorId'], doctor['_id']);
        expect(body['timeSlot'], '09:00 - 10:00');
        expect(body['reason'], 'Follow-up');
        return http.Response(
          jsonEncode({
            'data': {
              '_id': '507f1f77bcf86cd799439012',
              'appointmentDate': '2026-11-01T00:00:00.000Z',
              'timeSlot': '09:00 - 10:00',
              'reason': 'Follow-up',
              'status': 'pending',
              'paymentStatus': 'unpaid',
              'doctor': doctor,
            },
          }),
          201,
        );
      }),
    );
    final repository = AppointmentRepository(apiClient: client);

    final appointment = await repository.createAppointment(
      doctorId: doctor['_id'] as String,
      appointmentDate: DateTime.utc(2026, 11, 1),
      timeSlot: '09:00 - 10:00',
      reason: 'Follow-up',
    );

    expect(appointment.status, 'pending');
    expect(appointment.paymentStatus, 'unpaid');
  });

  test(
    'parses the SSLCommerz gateway session without treating it as success',
    () async {
      final client = ApiClient(
        client: MockClient((request) async {
          expect(request.url.path, '/api/v1/payments/sslcommerz/initiate');
          return http.Response(
            jsonEncode({
              'data': {
                'appointment': {'_id': 'appointment-1'},
                'transactionId': 'DA-transaction',
                'paymentAmount': 800,
                'currency': 'BDT',
                'gatewayPageURL': 'https://sandbox.sslcommerz.com/gateway',
              },
            }),
            200,
          );
        }),
      );
      final repository = PaymentRepository(apiClient: client);

      final session = await repository.initiateSslCommerzPayment(
        'appointment-1',
      );

      expect(session.gatewayPageUrl, contains('sslcommerz.com'));
      expect(session.transactionId, 'DA-transaction');
    },
  );
}
