import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:docvexa/core/network/api_client.dart';
import 'package:docvexa/core/network/api_exception.dart';

void main() {
  test('sends JSON and bearer headers to the configured route', () async {
    final client = ApiClient(
      baseUrl: 'https://example.test/api/v1',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/auth/login');
        expect(request.headers['authorization'], 'Bearer access-token');
        expect(jsonDecode(request.body), {'email': 'user@example.com'});
        return http.Response('{"ok":true}', 200);
      }),
    );

    final response = await client.post(
      '/auth/login',
      body: {'email': 'user@example.com'},
      accessToken: 'access-token',
    );

    expect(response['ok'], isTrue);
  });

  test('maps backend messages and status codes to ApiException', () async {
    final client = ApiClient(
      client: MockClient((_) async {
        return http.Response('{"message":"Invalid credentials"}', 401);
      }),
    );

    expect(
      () => client.post('/auth/login', body: {'email': 'user@example.com'}),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'status code', 401)
            .having((error) => error.message, 'message', 'Invalid credentials'),
      ),
    );
  });
}
