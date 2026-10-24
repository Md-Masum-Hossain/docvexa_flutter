import '../../../core/network/api_client.dart';
import 'doctor_models.dart';

class DoctorRepository {
  const DoctorRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<DoctorListResult> getDoctors({
    String? specialization,
    String? location,
    num? minFee,
    num? maxFee,
    num? rating,
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    _addIfPresent(query, 'specialization', specialization);
    _addIfPresent(query, 'location', location);
    _addIfPresent(query, 'minFee', minFee);
    _addIfPresent(query, 'maxFee', maxFee);
    _addIfPresent(query, 'rating', rating);

    final response = await apiClient.get(
      '/doctors?${Uri(queryParameters: query).query}',
    );
    return DoctorListResult.fromJson(_unwrap(response));
  }

  Future<Doctor> getDoctorById(String id) async {
    final response = await apiClient.get('/doctors/$id');
    return Doctor.fromJson(_unwrap(response));
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return response;
  }

  void _addIfPresent(Map<String, String> query, String key, Object? value) {
    if (value != null && value.toString().isNotEmpty) {
      query[key] = value.toString();
    }
  }
}
