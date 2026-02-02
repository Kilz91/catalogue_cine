import '../../../../core/error/failure.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/progress_entity.dart';

abstract class ProgressRepository {
  /// Récupérer la progression d'un média pour l'utilisateur
  Future<Either<Failure, ProgressEntity>> getMediaProgress({
    required int mediaId,
    required String mediaType,
  });

  /// Mettre à jour la progression d'un média
  Future<Either<Failure, void>> updateProgress({
    required int mediaId,
    required String mediaType,
    required int currentSeason,
    required int currentEpisode,
    required int totalEpisodes,
    required double percentage,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Créer une nouvelle progression pour un média
  Future<Either<Failure, ProgressEntity>> createProgress({
    required int mediaId,
    required String mediaType,
    required int totalEpisodes,
  });

  /// Obtenir toutes les progressions de l'utilisateur
  Future<Either<Failure, List<ProgressEntity>>> getUserProgressList();

  /// Supprimer la progression d'un média
  Future<Either<Failure, void>> deleteProgress({
    required int mediaId,
  });
}
