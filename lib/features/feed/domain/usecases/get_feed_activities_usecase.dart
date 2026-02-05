import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/activity_entity.dart';
import '../repositories/feed_repository.dart';

class GetFeedActivitiesUseCase {
  final FeedRepository repository;

  GetFeedActivitiesUseCase(this.repository);

  Future<Either<Failure, List<ActivityEntity>>> call() {
    return repository.getFeedActivities();
  }
}
