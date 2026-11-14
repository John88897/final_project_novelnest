/// Thrown when a service operation violates a business rule.
class ServiceException implements Exception {
  final String message;
  ServiceException(this.message);

  @override
  String toString() => 'ServiceException: $message';
}
