import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/progress_entity.dart';
import '../repositories/progress_repository.dart';

class GetMediaProgressUseCase
    implements UseCase<ProgressEntity, GetMediaProgressParams> {
  final ProgressRepository repository;

  GetMediaProgressUseCase(this.repository);

  @override
  Future<Either<Failure, ProgressEntity>> call(
    GetMediaProgressParams params,
  ) async {
    return await repository.getMediaProgress(
      mediaId: params.mediaId,
      mediaType: params.mediaType,
    );
  }
}

class GetMediaProgressParams {
  final int mediaId;
  final String mediaType;

  GetMediaProgressParams({
    required this.mediaId,
    required this.mediaType,
  });
}
