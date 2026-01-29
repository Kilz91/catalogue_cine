/// Exceptions pour la couche data
class AppException implements Exception {
  final String message;
  AppException(this.message);
}

/// Exception API
class ApiException extends AppException {
  final int? statusCode;
  ApiException(super.message, {this.statusCode});
}

/// Exception réseau
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Exception de cache
class CacheException extends AppException {
  CacheException(super.message);
}

/// Exception non authentifié
class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

/// Exception permission refusée
class PermissionDeniedException extends AppException {
  PermissionDeniedException(super.message);
}

/// Exception données non trouvées
class NotFoundException extends AppException {
  NotFoundException(super.message);
}
