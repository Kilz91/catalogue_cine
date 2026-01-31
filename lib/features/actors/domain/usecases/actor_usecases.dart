import '../entities/actor.dart';
import '../repositories/actor_repository.dart';
import '../../../catalog/domain/entities/media.dart';

/// Use case pour récupérer les détails d'un acteur
class GetActorDetailsUseCase {
  final ActorRepository repository;

  GetActorDetailsUseCase(this.repository);

  Future<Actor> call(int actorId) {
    return repository.getActorDetails(actorId);
  }
}

/// Use case pour récupérer la filmographie d'un acteur
class GetActorCreditsUseCase {
  final ActorRepository repository;

  GetActorCreditsUseCase(this.repository);

  Future<List<Media>> call(int actorId) {
    return repository.getActorCredits(actorId);
  }
}

/// Use case pour récupérer le cast d'un média
class GetMediaCastUseCase {
  final ActorRepository repository;

  GetMediaCastUseCase(this.repository);

  Future<List<Actor>> call({
    required int mediaId,
    required String mediaType,
  }) {
    return repository.getMediaCast(
      mediaId: mediaId,
      mediaType: mediaType,
    );
  }
}
