import '../../../core/network/api_client.dart';
import 'appointment_models.dart';

class AppointmentRepository {
  const AppointmentRepository({required this.apiClient, this.accessToken});

  final ApiClient apiClient;
  final String? accessToken;

  Future<Appointment> createAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    required String timeSlot,
    required String reason,
    String notes = '',
  }) async {
    final response = await apiClient.post(
      '/appointments',
      accessToken: accessToken,
      body: {
        'doctorId': doctorId,
        'appointmentDate': appointmentDate.toUtc().toIso8601String(),
        'timeSlot': timeSlot,
        'reason': reason,
        'notes': notes,
      },
    );
    return Appointment.fromJson(_unwrap(response));
  }

  Future<AppointmentListResult> getMyAppointments({
    int page = 1,
    int limit = 10,
    String? status,
    String? paymentStatus,
    String sortOrder = 'desc',
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      'sortOrder': sortOrder,
    };
    _add(query, 'status', status);
    _add(query, 'paymentStatus', paymentStatus);
    final response = await apiClient.get(
      '/appointments/my?${Uri(queryParameters: query).query}',
      accessToken: accessToken,
    );
    return AppointmentListResult.fromJson(_unwrap(response));
  }

  Future<Appointment> getAppointmentById(String id) async {
    final response = await apiClient.get(
      '/appointments/$id',
      accessToken: accessToken,
    );
    return Appointment.fromJson(_unwrap(response));
  }

  Future<Appointment> rescheduleAppointment({
    required String id,
    required DateTime appointmentDate,
    required String timeSlot,
    String? reason,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'appointmentDate': appointmentDate.toUtc().toIso8601String(),
      'timeSlot': timeSlot,
    };
    _add(body, 'reason', reason);
    _add(body, 'notes', notes);
    final response = await apiClient.patch(
      '/appointments/$id/reschedule',
      accessToken: accessToken,
      body: body,
    );
    return Appointment.fromJson(_unwrap(response));
  }

  Future<Appointment> cancelAppointment(String id) async {
    final response = await apiClient.delete(
      '/appointments/$id/cancel',
      accessToken: accessToken,
    );
    return Appointment.fromJson(_unwrap(response));
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> response) {
    final data = response['data'];
    return data is Map<String, dynamic> ? data : response;
  }

  void _add(Map<String, dynamic> map, String key, Object? value) {
    if (value != null && value.toString().trim().isNotEmpty) {
      map[key] = value;
    }
  }
}
