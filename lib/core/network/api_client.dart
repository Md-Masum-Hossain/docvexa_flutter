import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    this.baseUrl = AppConfig.apiBaseUrl,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  Future<Map<String, dynamic>> get(String path, {String? accessToken}) {
    return _send('GET', path, accessToken: accessToken);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    String? accessToken,
  }) {
    return _send('POST', path, body: body, accessToken: accessToken);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
    String? accessToken,
  }) {
    return _send('PATCH', path, body: body, accessToken: accessToken);
  }

  Future<Map<String, dynamic>> delete(String path, {String? accessToken}) {
    return _send('DELETE', path, accessToken: accessToken);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? body,
    String? accessToken,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    try {
      final request = http.Request(method, Uri.parse('$baseUrl$path'))
        ..headers.addAll(headers);
      if (body != null) {
        request.body = jsonEncode(body);
      }

      final response = await _client.send(request).timeout(timeout);
      final responseBody = await response.stream.bytesToString();
      final decoded = _decodeBody(responseBody);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _mapBackendError(response.statusCode, decoded);
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on async.TimeoutException {
      throw const TimeoutException();
    } on FormatException {
      throw const ApiException(message: 'The server returned invalid data.');
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const ApiException(
      message: 'The server returned an invalid response.',
    );
  }

  ApiException _mapBackendError(int statusCode, Map<String, dynamic> body) {
    final message = _findMessage(body) ?? _messageForStatus(statusCode);
    return ApiException(
      message: message,
      statusCode: statusCode,
      code: body['code']?.toString(),
    );
  }

  String? _findMessage(Map<String, dynamic> body) {
    for (final key in ['message', 'error', 'detail']) {
      final value = body[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  String _messageForStatus(int statusCode) {
    return switch (statusCode) {
      401 => 'Your session is not authorized.',
      403 => 'You do not have permission to perform this action.',
      404 => 'The requested resource was not found.',
      >= 500 => 'The Docvexa service is currently unavailable.',
      _ => 'The request could not be completed.',
    };
  }

  void close() => _client.close();
}
