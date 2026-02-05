import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';

/// Implémentation du repository Feed
class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;

  FeedRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ActivityEntity>>> getFeedActivities() async {
    try {
      final activities = await remoteDataSource.getFeedActivities();
      return Right(activities.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<RecommendationEntity>>> getRecommendations() async {
    try {
      final recommendations = await remoteDataSource.getRecommendations();
      return Right(recommendations.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logActivity({
    required String actionType,
    required String mediaId,
    required String mediaTitle,
    required String mediaPoster,
  }) async {
    try {
      await remoteDataSource.logActivity(
        actionType: actionType,
        mediaId: mediaId,
        mediaTitle: mediaTitle,
        mediaPoster: mediaPoster,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
