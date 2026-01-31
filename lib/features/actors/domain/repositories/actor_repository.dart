import '../entities/actor.dart';
import '../../../catalog/domain/entities/media.dart';

/// Repository abstrait pour les acteurs
abstract class ActorRepository {
  /// Récupérer les détails d'un acteur
  Future<Actor> getActorDetails(int actorId);

  /// Récupérer la filmographie d'un acteur
  Future<List<Media>> getActorCredits(int actorId);

  /// Récupérer le cast d'un média
  Future<List<Actor>> getMediaCast({
    required int mediaId,
    required String mediaType, // 'movie' ou 'tv'
  });
}
