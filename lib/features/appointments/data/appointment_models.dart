import '../../doctors/data/doctor_models.dart';

const appointmentStatuses = [
  'pending',
  'accepted',
  'confirmed',
  'cancelled',
  'completed',
  'rescheduled',
];

const paymentStatuses = [
  'unpaid',
  'pending',
  'paid',
  'failed',
  'cancelled',
  'refunded',
];

class Appointment {
  const Appointment({
    required this.id,
    required this.appointmentDate,
    required this.timeSlot,
    required this.reason,
    required this.notes,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.transactionId,
    required this.paymentAmount,
    required this.paidAt,
    required this.queueNumber,
    required this.doctor,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: _string(json['_id'] ?? json['id']),
      appointmentDate: _date(json['appointmentDate']),
      timeSlot: _string(json['timeSlot']),
      reason: _string(json['reason']),
      notes: _string(json['notes']),
      status: _string(json['status']),
      paymentStatus: _string(json['paymentStatus']),
      paymentMethod: _string(json['paymentMethod']),
      transactionId: _string(json['transactionId']),
      paymentAmount: json['paymentAmount'] is num
          ? (json['paymentAmount'] as num).toDouble()
          : null,
      paidAt: _date(json['paidAt']),
      queueNumber: json['queueNumber'] is num
          ? (json['queueNumber'] as num).toInt()
          : null,
      doctor: Doctor.fromJson(_map(json['doctor'])),
    );
  }

  final String id;
  final DateTime? appointmentDate;
  final String timeSlot;
  final String reason;
  final String notes;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String transactionId;
  final double? paymentAmount;
  final DateTime? paidAt;
  final int? queueNumber;
  final Doctor doctor;
}

class AppointmentListResult {
  const AppointmentListResult({required this.items, required this.pagination});

  factory AppointmentListResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return AppointmentListResult(
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(Appointment.fromJson)
                .toList()
          : const [],
      pagination: AppointmentPagination.fromJson(_map(json['pagination'])),
    );
  }

  final List<Appointment> items;
  final AppointmentPagination pagination;
}

class AppointmentPagination {
  const AppointmentPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory AppointmentPagination.fromJson(Map<String, dynamic> json) {
    return AppointmentPagination(
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

String _string(Object? value) => value is String ? value : '';

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

int _int(Object? value) => value is num ? value.toInt() : 0;

Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : const {};
