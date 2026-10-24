import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:docvexa/core/network/api_client.dart';
import 'package:docvexa/features/doctors/data/doctor_repository.dart';

void main() {
  test(
    'parses the doctor list envelope and supported query parameters',
    () async {
      final client = ApiClient(
        baseUrl: 'https://example.test/api/v1',
        client: MockClient((request) async {
          expect(request.url.path, '/api/v1/doctors');
          expect(request.url.queryParameters['specialization'], 'Cardiology');
          expect(request.url.queryParameters['location'], 'Dhanmondi');
          expect(request.url.queryParameters['sortBy'], 'ratingAverage');
          expect(request.url.queryParameters['sortOrder'], 'desc');
          return http.Response(
            jsonEncode({
              'statusCode': 200,
              'message': 'Doctors fetched successfully',
              'data': {
                'items': [
                  {
                    '_id': 'doctor-1',
                    'specialization': 'Cardiology',
                    'qualifications': ['MBBS'],
                    'experienceYears': 8,
                    'consultationFee': 800,
                    'ratingAverage': 4.8,
                    'ratingCount': 12,
                    'isVerified': true,
                    'user': {'name': 'Amina Rahman', 'role': 'doctor'},
                  },
                ],
                'pagination': {
                  'page': 1,
                  'limit': 10,
                  'total': 1,
                  'totalPages': 1,
                },
              },
            }),
            200,
          );
        }),
      );
      final repository = DoctorRepository(apiClient: client);

      final result = await repository.getDoctors(
        specialization: 'Cardiology',
        location: 'Dhanmondi',
        sortBy: 'ratingAverage',
      );

      expect(result.items.single.user.name, 'Amina Rahman');
      expect(result.items.single.ratingAverage, 4.8);
      expect(result.pagination.totalPages, 1);
    },
  );
}
