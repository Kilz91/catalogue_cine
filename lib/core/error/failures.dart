/// Failures pour la couche domain (utiliser Either)
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ApiFailure extends Failure {
  final int? statusCode;
  ApiFailure(super.message, {this.statusCode});
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure(super.message);
}

class PermissionDeniedFailure extends Failure {
  PermissionDeniedFailure(super.message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure(super.message);
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  UnknownFailure(super.message);
}
