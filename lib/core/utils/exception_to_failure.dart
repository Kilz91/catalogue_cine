import '../error/failures.dart';
import '../error/exceptions.dart';

/// Extension pour convertir exceptions en failures
extension ExceptionToFailure on AppException {
  Failure toFailure() {
    if (this is ApiException) {
      return ApiFailure(message, statusCode: (this as ApiException).statusCode);
    } else if (this is NetworkException) {
      return NetworkFailure(message);
    } else if (this is UnauthorizedException) {
      return UnauthorizedFailure(message);
    } else if (this is PermissionDeniedException) {
      return PermissionDeniedFailure(message);
    } else if (this is NotFoundException) {
      return NotFoundFailure(message);
    } else if (this is CacheException) {
      return CacheFailure(message);
    }
    return UnknownFailure(message);
  }
}
