import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/recommendation_entity.dart';

/// Repository abstract pour le feed
abstract class FeedRepository {
  Future<Either<Failure, List<ActivityEntity>>> getFeedActivities();
  Future<Either<Failure, List<RecommendationEntity>>> getRecommendations();
  Future<Either<Failure, void>> logActivity({
    required String actionType,
    required String mediaId,
    required String mediaTitle,
    required String mediaPoster,
  });
}
