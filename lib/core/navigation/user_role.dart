enum UserRole { patient, doctor, admin }

extension UserRoleLabel on UserRole {
  String get label {
    return switch (this) {
      UserRole.patient => 'Patient',
      UserRole.doctor => 'Doctor',
      UserRole.admin => 'Admin',
    };
  }
}
