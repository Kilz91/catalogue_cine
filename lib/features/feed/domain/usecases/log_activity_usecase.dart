import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/feed_repository.dart';

class LogActivityUseCase {
  final FeedRepository repository;

  LogActivityUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String actionType,
    required String mediaId,
    required String mediaTitle,
    required String mediaPoster,
  }) {
    return repository.logActivity(
      actionType: actionType,
      mediaId: mediaId,
      mediaTitle: mediaTitle,
      mediaPoster: mediaPoster,
    );
  }
}
