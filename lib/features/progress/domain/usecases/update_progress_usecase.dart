import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/progress_repository.dart';

class UpdateProgressUseCase implements UseCase<void, UpdateProgressParams> {
  final ProgressRepository repository;

  UpdateProgressUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProgressParams params) async {
    return await repository.updateProgress(
      mediaId: params.mediaId,
      mediaType: params.mediaType,
      currentSeason: params.currentSeason,
      currentEpisode: params.currentEpisode,
      totalEpisodes: params.totalEpisodes,
      percentage: params.percentage,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class UpdateProgressParams {
  final int mediaId;
  final String mediaType;
  final int currentSeason;
  final int currentEpisode;
  final int totalEpisodes;
  final double percentage;
  final DateTime? startDate;
  final DateTime? endDate;

  UpdateProgressParams({
    required this.mediaId,
    required this.mediaType,
    required this.currentSeason,
    required this.currentEpisode,
    required this.totalEpisodes,
    required this.percentage,
    this.startDate,
    this.endDate,
  });
}
