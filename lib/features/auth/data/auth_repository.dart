import '../../../core/network/api_client.dart';

/// The backend response contract must be supplied before this repository is wired.
/// Route paths are confirmed, but request fields, response envelopes, token keys,
/// and user fields are not available from the backend at implementation time.
class AuthRepository {
  const AuthRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> register(Map<String, dynamic> request) {
    return _apiClient.post('/auth/register', body: request);
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> request) {
    return _apiClient.post('/auth/login', body: request);
  }

  Future<Map<String, dynamic>> refreshToken(Map<String, dynamic> request) {
    return _apiClient.post('/auth/refresh-token', body: request);
  }

  Future<Map<String, dynamic>> logout({String? accessToken}) {
    return _apiClient.post('/auth/logout', accessToken: accessToken);
  }

  Future<Map<String, dynamic>> currentUser({required String accessToken}) {
    return _apiClient.get('/auth/me', accessToken: accessToken);
  }
}
