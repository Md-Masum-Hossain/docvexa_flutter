class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException({super.message = 'Unable to connect to Docvexa.'});
}

class TimeoutException extends ApiException {
  const TimeoutException({super.message = 'The request timed out.'});
}
