class Doctor {
  const Doctor({
    required this.id,
    required this.specialization,
    required this.qualifications,
    required this.experienceYears,
    required this.consultationFee,
    required this.bio,
    required this.hospitalName,
    required this.chamberAddress,
    required this.availableDays,
    required this.availableSlots,
    required this.isVerified,
    required this.ratingAverage,
    required this.ratingCount,
    required this.photoUrl,
    required this.user,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: _string(json['_id'] ?? json['id']),
      specialization: _string(json['specialization']),
      qualifications: _stringList(json['qualifications']),
      experienceYears: _number(json['experienceYears']),
      consultationFee: _number(json['consultationFee']),
      bio: _string(json['bio']),
      hospitalName: _string(json['hospitalName']),
      chamberAddress: _string(json['chamberAddress']),
      availableDays: _stringList(json['availableDays']),
      availableSlots: _slotList(json['availableSlots']),
      isVerified: json['isVerified'] == true,
      ratingAverage: _number(json['ratingAverage']),
      ratingCount: _number(json['ratingCount']),
      photoUrl: _string(json['photoUrl']),
      user: DoctorUser.fromJson(_map(json['user'])),
    );
  }

  final String id;
  final String specialization;
  final List<String> qualifications;
  final num experienceYears;
  final num consultationFee;
  final String bio;
  final String hospitalName;
  final String chamberAddress;
  final List<String> availableDays;
  final List<DoctorTimeSlot> availableSlots;
  final bool isVerified;
  final num ratingAverage;
  final num ratingCount;
  final String photoUrl;
  final DoctorUser user;
}

class DoctorUser {
  const DoctorUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.role,
  });

  factory DoctorUser.fromJson(Map<String, dynamic> json) {
    return DoctorUser(
      name: _string(json['name']),
      email: _string(json['email']),
      phone: _string(json['phone']),
      avatar: _string(json['avatar']),
      role: _string(json['role']),
    );
  }

  final String name;
  final String email;
  final String phone;
  final String avatar;
  final String role;
}

class DoctorTimeSlot {
  const DoctorTimeSlot({required this.startTime, required this.endTime});

  factory DoctorTimeSlot.fromJson(Map<String, dynamic> json) {
    return DoctorTimeSlot(
      startTime: _string(json['startTime']),
      endTime: _string(json['endTime']),
    );
  }

  final String startTime;
  final String endTime;
}

class DoctorPagination {
  const DoctorPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory DoctorPagination.fromJson(Map<String, dynamic> json) {
    return DoctorPagination(
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

class DoctorListResult {
  const DoctorListResult({required this.items, required this.pagination});

  factory DoctorListResult.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    return DoctorListResult(
      items: items is List
          ? items
                .whereType<Map<String, dynamic>>()
                .map(Doctor.fromJson)
                .toList()
          : const [],
      pagination: DoctorPagination.fromJson(_map(json['pagination'])),
    );
  }

  final List<Doctor> items;
  final DoctorPagination pagination;
}

String _string(Object? value) => value is String ? value : '';

num _number(Object? value) => value is num ? value : 0;

int _int(Object? value) => value is num ? value.toInt() : 0;

List<String> _stringList(Object? value) {
  return value is List ? value.whereType<String>().toList() : const [];
}

List<DoctorTimeSlot> _slotList(Object? value) {
  return value is List
      ? value
            .whereType<Map<String, dynamic>>()
            .map(DoctorTimeSlot.fromJson)
            .toList()
      : const [];
}

Map<String, dynamic> _map(Object? value) {
  return value is Map<String, dynamic> ? value : const {};
}
