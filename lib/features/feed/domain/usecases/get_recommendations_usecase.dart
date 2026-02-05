import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/recommendation_entity.dart';
import '../repositories/feed_repository.dart';

class GetRecommendationsUseCase {
  final FeedRepository repository;

  GetRecommendationsUseCase(this.repository);

  Future<Either<Failure, List<RecommendationEntity>>> call() {
    return repository.getRecommendations();
  }
}
