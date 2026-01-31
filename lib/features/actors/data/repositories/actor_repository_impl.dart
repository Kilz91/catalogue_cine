import '../../domain/entities/actor.dart';
import '../../domain/repositories/actor_repository.dart';
import '../datasources/tmdb_actor_data_source.dart';
import '../../../catalog/domain/entities/media.dart';

/// Implémentation du repository acteur
class ActorRepositoryImpl implements ActorRepository {
  final TmdbActorDataSource tmdbDataSource;

  ActorRepositoryImpl({required this.tmdbDataSource});

  @override
  Future<Actor> getActorDetails(int actorId) async {
    final model = await tmdbDataSource.getActorDetails(actorId);
    return model.toEntity();
  }

  @override
  Future<List<Media>> getActorCredits(int actorId) async {
    final models = await tmdbDataSource.getActorCredits(actorId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Actor>> getMediaCast({
    required int mediaId,
    required String mediaType,
  }) async {
    final models = await tmdbDataSource.getMediaCast(
      mediaId: mediaId,
      mediaType: mediaType,
    );
    return models.map((model) => model.toEntity()).toList();
  }
}
