import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_datasource.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressRemoteDataSource remoteDataSource;

  ProgressRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ProgressEntity>> getMediaProgress({
    required int mediaId,
    required String mediaType,
  }) async {
    try {
      final model = await remoteDataSource.getMediaProgress(
        mediaId: mediaId,
        mediaType: mediaType,
      );

      return Right(
        ProgressEntity(
          id: model.id,
          userId: model.userId,
          mediaId: model.mediaId,
          mediaType: model.mediaType,
          currentSeason: model.currentSeason,
          currentEpisode: model.currentEpisode,
          totalEpisodes: model.totalEpisodes,
          percentage: model.percentage,
          startDate: model.startDate,
          endDate: model.endDate,
          lastUpdated: model.lastUpdated,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure('Erreur lors de la récupération: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateProgress({
    required int mediaId,
    required String mediaType,
    required int currentSeason,
    required int currentEpisode,
    required int totalEpisodes,
    required double percentage,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await remoteDataSource.updateProgress(
        mediaId: mediaId,
        mediaType: mediaType,
        currentSeason: currentSeason,
        currentEpisode: currentEpisode,
        totalEpisodes: totalEpisodes,
        percentage: percentage,
        startDate: startDate,
        endDate: endDate,
      );

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Erreur lors de la mise à jour: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ProgressEntity>> createProgress({
    required int mediaId,
    required String mediaType,
    required int totalEpisodes,
  }) async {
    try {
      final model = await remoteDataSource.createProgress(
        mediaId: mediaId,
        mediaType: mediaType,
        totalEpisodes: totalEpisodes,
      );

      return Right(
        ProgressEntity(
          id: model.id,
          userId: model.userId,
          mediaId: model.mediaId,
          mediaType: model.mediaType,
          currentSeason: model.currentSeason,
          currentEpisode: model.currentEpisode,
          totalEpisodes: model.totalEpisodes,
          percentage: model.percentage,
          startDate: model.startDate,
          endDate: model.endDate,
          lastUpdated: model.lastUpdated,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure('Erreur lors de la création: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProgressEntity>>> getUserProgressList() async {
    try {
      final models = await remoteDataSource.getUserProgressList();

      final entities = models.map((model) {
        return ProgressEntity(
          id: model.id,
          userId: model.userId,
          mediaId: model.mediaId,
          mediaType: model.mediaType,
          currentSeason: model.currentSeason,
          currentEpisode: model.currentEpisode,
          totalEpisodes: model.totalEpisodes,
          percentage: model.percentage,
          startDate: model.startDate,
          endDate: model.endDate,
          lastUpdated: model.lastUpdated,
        );
      }).toList();

      return Right(entities);
    } catch (e) {
      return Left(
        ServerFailure('Erreur lors de la récupération: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteProgress({required int mediaId}) async {
    try {
      await remoteDataSource.deleteProgress(mediaId: mediaId);

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Erreur lors de la suppression: ${e.toString()}'),
      );
    }
  }
}
