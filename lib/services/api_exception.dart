/// Thrown by service classes when the backend returns a non-2xx response
/// or the request fails outright (timeout, no connection, etc).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
